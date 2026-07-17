# AGENTS.md — Restaurant POS build instructions

You are building a production-style Restaurant POS backend (Node/Express + PostgreSQL + Prisma + Socket.io), following the full spec in `docs/SPEC.md`. Read that file first before writing any code — it has the complete schema, API design, and architecture decisions already made. Do not redesign the architecture; implement it.

## Ground rules

1. **Use Prisma as the ORM, never raw SQL.** This is deliberate — it keeps a future SQLite migration cheap (see SPEC.md section 7). All queries go through `prisma.<model>.<method>()`.
2. **Follow the modular monolith folder structure already scaffolded** (`src/modules/<domain>/`). Each domain gets its own `routes.js`, `controller.js`, `service.js`, `schema.js`. Do not put business logic in controllers — controllers only handle req/res; services contain the logic and know nothing about HTTP.
3. **Every multi-table write must be a Prisma transaction** (`prisma.$transaction(...)`). This applies especially to order creation (order + order_items + stock decrement + status history in one atomic transaction).
4. **Validate every request body with Zod** before it reaches a service function. Reject invalid input with a 422 and a clear message.
5. **Every route must declare required roles** via the `requireRole()` middleware. Never leave a route unguarded except `/auth/login` and `/health`.
6. **All errors flow through the single centralized error handler** (`middleware/error.middleware.js`). Never send ad-hoc error responses from a controller.
7. **Write a test for every service function that touches money, stock, or order status.** Use Jest + Supertest. Don't move to the next phase until tests for the current phase pass.
8. **Prices are `Decimal`/`NUMERIC`, never floats.** Follow this in the Prisma schema and in all calculations.
9. **Ask before installing a new dependency** that isn't already listed in the setup steps — don't silently add packages.
10. **After finishing each phase below, stop and summarize what you built, then wait for confirmation** before starting the next phase. Don't build multiple phases in one pass — this is a learning project, not just a delivery, so the person building it needs to review and understand each phase.

## Build order — do not skip ahead

### Phase 1 — Foundations
- Implement the full Prisma schema from `docs/SPEC.md` (all tables: branches, users, categories, products, ingredients, recipe_items, restaurant_tables, orders, order_items, order_status_history, payments, print_jobs).
- Run the initial migration.
- Set up `src/app.js` (Express app, helmet, cors, rate limiting) and `server.js` (HTTP server + Socket.io init).
- Add `GET /api/v1/health` that checks DB connectivity.
- Add a `prisma/seed.js` that creates one branch and one admin user.

### Phase 2 — Auth & RBAC
- `POST /api/v1/auth/login` (bcrypt compare, issue access + refresh token).
- `POST /api/v1/auth/refresh`.
- `auth.middleware.js` (verify JWT, attach `req.user`).
- `rbac.middleware.js` (`requireRole(...)`).
- Seed script extended with one test user per role (admin, manager, cashier, kitchen).

### Phase 3 — Menu & stock API
- CRUD for categories, products, ingredients, recipe_items.
- Enforce admin/manager-only writes; authenticated-only reads.

### Phase 4 — Orders core
- `POST /api/v1/orders` — full transaction: create order, create order_items, atomically decrement stock (conditional `updateMany`, not read-then-write), write order_status_history.
- `PATCH /api/v1/orders/:id/status` — enforce the status state machine from SPEC.md, reject invalid transitions with 422.
- `GET /api/v1/orders` with pagination and status/date filtering.

### Phase 5 — Real-time layer
- Socket.io rooms scoped by `branch:{id}` and `branch:{id}:kitchen`.
- Emit `order:created` on order creation, `order:updated` on status change.

### Phase 6 — Printer integration
- `printService.js` using `node-thermal-printer` over TCP.
- Retry-with-backoff (3 attempts) writing to `print_jobs`, emitting `printer:error` on final failure.

### Phase 7 — Tests & polish
- Integration tests covering: insufficient stock rejection, invalid status transition rejection, role-guard rejection, full happy-path order creation.

## What NOT to do
- Don't add MongoDB, GraphQL, or any tech not in the spec — the stack is fixed.
- Don't skip validation "for now" — add it at the same time as the route.
- Don't write a giant single `routes.js`/`controller.js` — keep the per-module split.
- Don't invent new database fields not in `docs/SPEC.md` without flagging it first.