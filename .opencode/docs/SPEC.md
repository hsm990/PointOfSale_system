# Restaurant POS — Build Spec (condensed, for AI agent reference)

Full rationale is in the PDF (`restaurant-pos-system-spec.pdf`) in project docs — this file is the distilled, implementation-ready version for the coding agent.

## Stack
Node.js + Express, PostgreSQL via Prisma, Socket.io, JWT auth (access + refresh), Zod validation, bcrypt, Jest + Supertest.

## Database schema (Prisma-equivalent, see PDF section 4 for full DDL)

- **branches**: id, name, address, created_at
- **users**: id, branch_id→branches, full_name, email (unique), password_hash, role (enum: admin/manager/cashier/kitchen), is_active, created_at
- **categories**: id, branch_id→branches, name, sort_order
- **products**: id, branch_id→branches, category_id→categories, name, price (Decimal), is_available, created_at
- **ingredients**: id, branch_id→branches, name, unit, stock_qty (Decimal), low_stock_at (Decimal)
- **recipe_items**: product_id→products, ingredient_id→ingredients, qty_required (Decimal) — composite PK
- **restaurant_tables**: id, branch_id→branches, label, seats, status
- **orders**: id, branch_id→branches, table_id→restaurant_tables (nullable), cashier_id→users, order_type (enum: dine_in/takeaway/delivery), status (enum: pending/confirmed/preparing/ready/served/paid/cancelled), subtotal, total, created_at, updated_at
- **order_items**: id, order_id→orders, product_id→products, quantity, unit_price (snapshot at order time), notes
- **order_status_history**: id, order_id→orders, from_status, to_status, changed_by→users, changed_at
- **payments**: id, order_id→orders, method (enum: cash/card/wallet), amount, paid_at
- **print_jobs**: id, order_id→orders, printer_ip, status (enum: queued/sent/failed), attempts, last_error, created_at

Indexes: `(branch_id, status)` on orders, `(order_id)` on order_items, `(branch_id, category_id)` on products.

## Order status state machine (enforce in service layer, not just DB)
```
pending   → confirmed | cancelled
confirmed → preparing | cancelled
preparing → ready
ready     → served
served    → paid
paid      → (terminal)
cancelled → (terminal)
```

## API summary

| Method | Endpoint | Role | Notes |
|---|---|---|---|
| POST | /api/v1/auth/login | public | returns access token, sets refresh cookie |
| POST | /api/v1/auth/refresh | authenticated | new access token |
| GET | /api/v1/products | authenticated | filter by category |
| POST | /api/v1/products | admin, manager | |
| PATCH | /api/v1/products/:id | admin, manager | |
| GET | /api/v1/orders | authenticated | filter by status/date, paginated |
| POST | /api/v1/orders | cashier, admin, manager | transactional, see below |
| PATCH | /api/v1/orders/:id/status | kitchen, cashier, admin | validated state machine |
| POST | /api/v1/orders/:id/payments | cashier, admin | supports split payments |
| GET | /api/v1/reports/sales | admin, manager | date range aggregation |
| GET | /api/v1/ingredients/low-stock | admin, manager | below low_stock_at |
| GET | /api/v1/health | public | DB connectivity check |

## Order creation transaction (critical path — must be atomic)
1. Begin `prisma.$transaction`.
2. Create order row.
3. Create order_items rows.
4. For each recipe_item tied to ordered products, atomically decrement ingredient stock using a conditional `updateMany` (`where: { stockQty: { gte: required } }`) — never read-then-write, to avoid race conditions.
5. If any decrement affects 0 rows → throw, whole transaction rolls back, return 409.
6. Write order_status_history row (to_status: pending).
7. Commit.
8. After commit: emit `order:created` via Socket.io to `branch:{id}:kitchen` room, enqueue a print job.

## Real-time events
- Clients join `branch:{id}` on connect; kitchen-role clients also join `branch:{id}:kitchen`.
- `order:created` → emitted to kitchen room on new order.
- `order:updated` → emitted to full branch room on status change.
- `printer:error` → emitted to kitchen room when a print job fails after 3 retries.

## Printer integration
- `node-thermal-printer` over TCP (`tcp://<printer_ip>:9100`), ESC/POS protocol.
- Retry 3 times with backoff (1s, 2s, 3s) on failure; log to `print_jobs`; emit `printer:error` on final failure.

## Security requirements
- bcrypt for passwords, never plain text.
- JWT access token short-lived (15 min), refresh token in httpOnly secure cookie (7 days).
- Rate limit `/auth/login` (5 attempts / 15 min / IP).
- helmet + explicit CORS allow-list.
- All input validated with Zod before hitting a service function.

## Full build order
See `AGENTS.md` in the project root — phases 1 through 7, one at a time, with a stop-and-review checkpoint after each phase.