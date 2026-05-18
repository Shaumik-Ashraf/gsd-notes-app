---
last_mapped: 2026-05-18
---

# External Integrations

## Database

| Service | Adapter | Config |
|---------|---------|--------|
| SQLite3 | `sqlite3` gem | `config/database.yml` |

All environments use SQLite3. No external database server. Databases stored in `storage/` directory, which is mounted as a persistent Docker volume in production.

## File Storage

| Service | Adapter | Used When |
|---------|---------|-----------|
| Local disk | `:local` | Development |
| Local disk | `:disk` (tmp/storage) | Test |
| Not configured | — | Production (placeholder config for S3/GCS exists but commented out) |

Config: `config/storage.yml`. Active Storage enabled via `gem "image_processing", "~> 1.2"` for image variants.

## Email

**Action Mailer** — configured for development localhost (`host: "localhost", port: 3000`). No external email provider configured yet. Delivery errors suppressed in development (`raise_delivery_errors = false`).

## Container Registry

Local registry at `localhost:5555` (Kamal config in `config/deploy.yml`). Password sourced from `config/master.key` via `.kamal/secrets`.

## CI/CD

**GitHub Actions** — defined in `.github/workflows/ci.yml`. Four jobs:
- `scan_ruby` — Brakeman + bundler-audit
- `scan_js` — `bin/importmap audit`
- `lint` — RuboCop with caching
- `test` — minitest suite

Triggered on: pull requests and pushes to `main`.

## Secrets Management

- Rails encrypted credentials (`config/credentials.yml.enc` / `config/master.key`)
- Kamal reads `RAILS_MASTER_KEY` from `config/master.key` at deploy time
- Parameter filtering configured for: `:passw`, `:email`, `:secret`, `:token`, `:_key`, `:crypt`, `:salt`, `:certificate`, `:otp`, `:ssn`, `:cvv`, `:cvc`

## Not Yet Integrated

- No OAuth / SSO provider
- No Redis (using Solid Cache/Queue/Cable instead)
- No external search (Elasticsearch, Algolia, etc.)
- No payment processor
- No analytics/observability (APM, error tracking)
- No push notifications
- No external CDN (assets served via Thruster)
