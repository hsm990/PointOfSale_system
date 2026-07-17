# Restaurant POS System

A multi-tenant restaurant point-of-sale and kitchen management system, built as a portfolio-grade backend learning project.

**Stack:** React (TypeScript) · Node.js / Express · PostgreSQL + Prisma · Socket.io · JWT auth · ESC/POS thermal printer integration

Full architecture, database schema, and API design: see [`docs/SPEC.md`](./docs/SPEC.md). Build workflow for AI coding agents: see [`AGENTS.md`](./AGENTS.md).

---

## Project structure

```
restaurant-pos/
├── AGENTS.md              # build workflow/instructions for AI coding agents
├── docker-compose.yml     # local Postgres + backend, containerized
├── docs/
│   └── SPEC.md             # full schema, API reference, architecture decisions
├── backend/
│   ├── src/
│   │   ├── config/         # db connection, env validation
│   │   ├── modules/        # auth, products, orders, reports (routes/controller/service/schema per domain)
│   │   ├── realtime/        # Socket.io setup + event constants
│   │   ├── printing/        # ESC/POS printer service + retry queue
│   │   ├── middleware/       # auth, RBAC, validation, error handling
│   │   └── utils/
│   ├── prisma/
│   │   ├── schema.prisma
│   │   └── migrations/
│   ├── tests/
│   │   ├── unit/
│   │   └── integration/
│   └── server.js
└── frontend/
    ├── apps/
    │   ├── cashier/         # POS ordering screen
    │   ├── kitchen/          # kitchen display, real-time order queue
    │   └── admin/            # menu/stock management, reports
    └── packages/
        ├── api-client/       # shared typed fetch wrapper + React Query hooks
        ├── socket-client/     # shared Socket.io connection logic
        └── ui/                 # shared design system components
```

---

## Getting started

### Prerequisites
- Node.js 18+
- PostgreSQL 16 (local install, or via Docker — see below)
- npm

### 1. Clone and install backend dependencies
```bash
cd backend
npm install
```

### 2. Configure environment variables
```bash
cp .env.example .env
```
Then edit `.env` and set a real `DATABASE_URL`, `JWT_ACCESS_SECRET`, and `JWT_REFRESH_SECRET`.

### 3. Start PostgreSQL

**Option A — Docker (recommended, no local Postgres install needed):**
```bash
# from the project root
docker compose up -d
```

**Option B — local PostgreSQL install:**
Make sure Postgres is running and `DATABASE_URL` in `.env` points to it.

### 4. Run migrations and seed data
```bash
cd backend
npx prisma migrate dev
npx prisma db seed
```

### 5. Start the backend in dev mode
```bash
npm run dev
```
The API should now be running at `http://localhost:4000`. Check it with:
```bash
curl http://localhost:4000/api/v1/health
```

### 6. Frontend (once you reach that phase)
```bash
cd frontend/apps/cashier
npm install
npm run dev
```
(repeat for `kitchen` and `admin` apps)

---

## Useful scripts (backend)

| Command | What it does |
|---|---|
| `npm run dev` | Start the server with nodemon (auto-restart on save) |
| `npm test` | Run the Jest test suite |
| `npx prisma studio` | Open a GUI to browse/edit the database |
| `npx prisma migrate dev` | Create and apply a new migration |
| `npx prisma generate` | Regenerate the Prisma client after schema changes |

---

## Build status / roadmap

This project is built in phases — see `AGENTS.md` for the full breakdown. Check off as you complete each:

- [ ] Phase 1 — Foundations (schema, migrations, health check)
- [ ] Phase 2 — Auth & RBAC
- [ ] Phase 3 — Menu & stock API
- [ ] Phase 4 — Orders core (transactions, state machine)
- [ ] Phase 5 — Real-time layer (Socket.io)
- [ ] Phase 6 — Printer integration (ESC/POS)
- [ ] Phase 7 — Tests & polish
- [ ] Phase 8 — Frontend build-out
- [ ] Phase 9 — Deployment

---

## Notes

- Prices are stored as `Decimal`/`NUMERIC`, never floats — this matters for financial accuracy.
- All multi-table writes (e.g. order creation) run inside a Prisma transaction — see `docs/SPEC.md` for why.
- The schema is designed to be portable to SQLite for a local-first deployment variant later (see `docs/SPEC.md` section on deployment strategy) — avoid raw SQL so this stays cheap to do.