---
last_mapped: 2026-05-18
---

# Technical Concerns

## Current State Assessment

This is a **freshly generated Rails 8.1 skeleton**. No domain code has been written yet. Concerns are infrastructure/configuration level only — there is no accumulated technical debt.

## Greenfield Risks

### No Authentication
- No `bcrypt` (commented out in Gemfile), no Devise, no Auth0
- Any feature requiring user identity must add this from scratch
- Rails 8.1 ships a generator for basic authentication (`rails generate authentication`) — worth using before building custom alternatives

### No Domain Models
- Zero custom models, zero migrations run
- `config/routes.rb` has only the `/up` health check
- Application is not functional in any domain sense yet

### SQLite in Production
- SQLite works well for single-server deployments (Rails 8 made this viable)
- Scaling beyond one server requires migrating to PostgreSQL/MySQL
- Production uses multiple SQLite files (primary, cache, queue, cable) — adds operational complexity vs a single server
- Deployment target in `config/deploy.yml` is a single server (`192.168.0.1`) — appropriate for now

## Security Concerns

### Content Security Policy Disabled
- `config/initializers/content_security_policy.rb` exists but is entirely commented out
- No CSP headers sent — XSS protections rely only on Rails' default HTML escaping
- Should be enabled before any user-facing content is shipped

### Master Key in Repo Awareness
- `config/master.key` exists (not gitignored — it IS gitignored via `.gitignore`)
- `.kamal/secrets` reads it for deployment — this file must not be committed
- Credentials encrypted with this key: `config/credentials.yml.enc`

### Browser Restriction
- `allow_browser versions: :modern` in `ApplicationController` — blocks IE and very old browsers
- This is intentional, not a concern, but worth noting for user reach decisions

## Performance Considerations

### jemalloc in Production Only
- jemalloc enabled via `LD_PRELOAD` in production Docker image
- Development runs without it — memory behavior differs between environments

### No Caching in Development
- `config.action_controller.perform_caching = false` in development
- Solid Cache configured but not exercised during development

## Infrastructure Concerns

### Docker Registry
- `config/deploy.yml` points to `localhost:5555` — a local registry
- Not suitable for team or multi-server deployment without updating to Docker Hub / ghcr.io / etc.

### PWA Support Incomplete
- `app/views/pwa/manifest.json.erb` and `service-worker.js` exist
- PWA routes commented out in `config/routes.rb`
- Not functional as a PWA until routes are enabled and manifest is populated

### Image Processing
- `gem "image_processing", "~> 1.2"` installed for Active Storage image variants
- `libvips` required at runtime — included in Dockerfile and CI, but must be present on any dev machine running image-related tests

## Code Quality

### No TODO/FIXME/HACK Markers
- No technical debt markers in source (clean slate)

### No Custom Error Handling
- Public error pages exist in `public/` but no custom error handling logic
- Errors will surface as unformatted 500 pages in production without additional setup

## Dependency Freshness

- `gem "rails", "~> 8.1.3"` — current stable release (May 2026)
- `ruby "4.0.1"` — very recent Ruby version (released 2025)
- Dependabot configured (`.github/dependabot.yml`) — automated dependency update PRs
