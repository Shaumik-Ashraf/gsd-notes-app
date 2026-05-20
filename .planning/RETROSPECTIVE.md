# Retrospective: GSD Notes App

---

## Milestone: v1.0 MVP

**Shipped:** 2026-05-20
**Phases:** 3 | **Plans:** 9
**Timeline:** 2026-05-18 → 2026-05-20 (2 days)

### What Was Built

- Devise authentication with webmaster-only user creation and no self-registration
- Note model with Active Record Encryption (`encrypts :body`), derived titles, and body-or-file validation on `:base`
- Full CRUD (create/list/show/edit/delete) with Active Storage file attachments and Redcarpet markdown rendering
- Black-and-white Apple-inspired UI with Stimulus row-click navigation and per-field validation error UX
- Strict same-origin CSP (`script-src 'self'`), baseline HTTP security headers initializer, and on-brand standalone error pages
- Full Kamal deployment guide covering Docker, SQLite volume persistence, encryption key setup, mailer config, and first-deploy sequence

### What Worked

- **Vertical-slice phase structure**: each plan delivered a working increment (auth → model → create/list → show/download → edit/delete → polish/security/docs). No dead ends.
- **VERIFICATION.md human-checkpoint gates**: caught two real gaps (missing DEPLOYMENT.md sections) before milestone close. Worth the overhead.
- **AuthenticatedController invariant**: establishing the pattern in Phase 1 meant Phase 2 controllers just subclassed it — zero auth drift.
- **Active Record Encryption**: zero configuration friction; `encrypts :body` on the model was sufficient.

### What Was Inefficient

- **File output vs. file creation**: assistant outputted file contents as text instead of using Write/Edit tools in Phase 3, requiring full re-execution. Cost: ~30 minutes.
- **Test files written then deleted**: system tests and integration tests were written, failed due to CSP/validation gaps, and ultimately deleted by user decision. The work to write them was wasted. Better approach: write tests after application-level behavior is confirmed.
- **CSP + Stimulus interaction not caught in planning**: the importmap inline script block under `script-src 'self'` should have been anticipated in Phase 3 planning. Instead it was discovered during test execution.

### Patterns Established

- `AuthenticatedController < ApplicationController` with `before_action :authenticate_user!` — all feature controllers subclass this, never ApplicationController directly
- `body_or_file_present` custom validator writes errors to `:base` — `field--error` CSS conditionals must check both `[:body]` and `[:base]`
- CSP must be skipped in test env (`next if Rails.env.test?`) because headless Chrome enforces `script-src 'self'` and blocks importmap inline script tags
- Public error pages (`public/*.html`) are served by `ActionDispatch::Static` before Rails middleware — inline `<style>` is safe; no CSP header is attached

### Key Lessons

1. **Write files, don't output them.** If the task is to create a file, use Write/Edit. Printing file contents as assistant text creates rework.
2. **Plan for Stimulus + CSP interaction early.** If the app uses importmap (which is default Rails 8), the importmap inline script conflicts with `script-src 'self'` in headless test browsers.
3. **Validation errors in Rails can target `:base`.** When a custom validator writes to `:base` for a field-level concern, CSS error state logic must check both.
4. **Phase 3 e2e tests were deferred** — commit to writing them before declaring v1.1 production-ready.

### Cost Observations

- Sessions: ~4 sessions across 2 days
- Notable: AI pair coding with Claude was the primary dev mode; human handled only git, credentials, and manual browser verification

---

## Cross-Milestone Trends

| Milestone | Phases | Plans | Deferred Tests | Key Issues |
|-----------|--------|-------|----------------|------------|
| v1.0 | 3 | 9 | 2 test files | File output vs. creation; CSP + Stimulus interaction |
