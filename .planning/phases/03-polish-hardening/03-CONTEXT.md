# Phase 3: Polish & Hardening - Context

**Gathered:** 2026-05-20
**Status:** Ready for planning

<domain>
## Phase Boundary

Make the app production-ready: apply Apple-inspired UI polish across all pages (notes table, forms, show page, nav, error pages), configure security hardening (strict CSP, standard HTTP headers), style public error pages, and produce deployment documentation (DEPLOYMENT.md + production.rb comments). No new functional requirements — this phase improves quality and hardening across Phase 1 & 2 deliverables.

</domain>

<decisions>
## Implementation Decisions

### UI Polish

- **D-UI-01:** Use a **simple but polished Apple-inspired aesthetic** across all pages. Color palette: **black and white only** (no color accents). System-ui font stack already in place. Design language targets clean spacing, bold typography, subtle borders — consistent with the existing sign-in card style.
- **D-UI-02:** Notes index table — **row click navigates to the note show page**. Edit and delete actions live in a dedicated **last column** (icon buttons or small text links). No per-row inline expansion.
- **D-UI-03:** Note body editor (create and edit forms) — **plain styled `<textarea>` with a label/placeholder** ("Write your note in markdown"). No JS markdown editor widget.
- **D-UI-04:** Note show page — **Edit and Delete buttons in a top-right action bar**. Delete requires a confirmation (Rails `data: { turbo_confirm: "..." }` or `data-confirm`). No bottom-of-page actions.
- **D-UI-05:** Nav bar — **"Notes" as a text wordmark, left-aligned**. Sign-out link right-aligned. Clean single-line header.
- **D-UI-06:** "New Note" button — **top-right of the notes index page**. Solid dark fill (black or near-black background, white text). Primary action button style matching Apple's pattern.

### Validation Error UX

- **D-ERR-01:** Validation errors — display inline per field AND a summary at the top of the form (standard Rails error render pattern: `@note.errors` shown above the form fields). CSS must style error states: red text or border for invalid fields. Applies to both notes forms and sign-in (wrong credentials).
- **D-ERR-02:** Sign-in with wrong credentials already shows "Invalid email or password." (from Phase 1 D-06). No change needed there beyond confirming the styling matches the new design.

### Mailer for Password Recovery

- **D-MAIL-01:** Do **NOT** wire up a specific ActionMailer delivery provider in Phase 3. The app stays as-is (`:recoverable` installed, no delivery configured). This is intentional — different deployments may use sendmail, Gmail SMTP, Postmark, etc.
- **D-MAIL-02:** Document how to configure mailer for production in **two places**: (1) a new **`DEPLOYMENT.md`** file at the repo root with a step-by-step walkthrough including sendmail and Gmail SMTP examples; (2) **inline comments in `config/environments/production.rb`** showing the `config.action_mailer` settings to uncomment and fill in.

### Security Hardening

- **D-SEC-01:** **Enable strict CSP** by uncommenting and configuring `config/initializers/content_security_policy.rb`. Policy: same-origin scripts (`script-src :self`), no inline JS, no `eval`. Must not break Turbo/Stimulus (both are served from the asset pipeline, so `:self` is sufficient).
- **D-SEC-02:** **Style all public error pages** (`public/404.html`, `public/422.html`, `public/500.html`) to match the Apple-inspired aesthetic. A clean centered message with the app name is sufficient — these are standalone HTML files (no Rails layout).
- **D-SEC-03:** **Add standard HTTP security headers**: `X-Frame-Options: SAMEORIGIN`, `X-Content-Type-Options: nosniff`. HSTS (`Strict-Transport-Security`) in production only. Configure via `config/initializers/` or `config/application.rb` Rack middleware.

### Deployment Documentation

- **D-DEPLOY-01:** **Audit `config/deploy.yml` and `Dockerfile` for correctness** — check for placeholder values, missing env vars, and configuration gaps.
- **D-DEPLOY-02:** Write **`DEPLOYMENT.md`** at the repo root with a walkthrough covering: prerequisites (Docker, Kamal CLI), container registry setup, server configuration, secrets/credentials setup, `RAILS_MASTER_KEY`, first deploy command sequence, and how to verify the running app.

### Claude's Discretion

- Exact CSS values within the black-and-white Apple aesthetic (border widths, font sizes, spacing scale)
- Specific icon choice for edit/delete in the table (SVG inline, text symbols, or Unicode)
- Title truncation exact character limit (aim for ~60-80 chars with CSS `text-overflow: ellipsis`)
- Which Rack middleware approach for HTTP headers (many valid options in Rails)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Scope & Constraints
- `.planning/ROADMAP.md` — Phase 3 goal, success criteria, and phase boundary (cross-cutting, no new REQ-IDs)
- `.planning/PROJECT.md` — Core constraints (Active Record Encryption non-negotiable, Rails 8.1 only, no self-registration)
- `.planning/REQUIREMENTS.md` — Full v1 requirement traceability; Phase 3 has no new requirements but must not break any

### Prior Phase Decisions (architectural invariants)
- `.planning/phases/01-authentication-user-foundation/01-CONTEXT.md` — D-05 through D-08: sign-in page UX, generic error message, session behavior; D-12/D-13: AuthenticatedController pattern
- `.planning/phases/02-notes-crud-with-encryption/02-CONTEXT.md` — D-01/D-02: Redcarpet + SanitizeHelper for markdown rendering; D-06/D-07: attachment edit/delete behavior; D-08: plain textarea decision (Phase 3 keeps this)

### Codebase Files to Read
- `app/assets/stylesheets/application.css` — existing CSS to extend (sign-in styles already defined; notes table/form styles to add)
- `config/initializers/content_security_policy.rb` — commented-out CSP to enable
- `config/environments/production.rb` — add ActionMailer and HTTP header configs here
- `public/404.html`, `public/422.html`, `public/500.html` — static error pages to restyle
- `config/deploy.yml` — Kamal config to audit and document
- `Dockerfile` — Docker config to audit

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `app/assets/stylesheets/application.css` — single CSS manifest with sign-in card styles already defined; all new styles (notes table, forms, nav bar, error pages) added here
- `app/views/layouts/application.html.erb` — nav bar lives here; breadcrumb and "Notes" wordmark added to this layout
- `app/views/notes/` — `index.html.erb`, `show.html.erb`, `edit.html.erb`, `new.html.erb`, `_form.html.erb` all need styling

### Established Patterns
- Standard Rails MVC — no client-side framework; CSS classes applied directly in ERB
- Turbo Drive — `data: { turbo_confirm: "..." }` for delete confirmation (no custom JS needed)
- Devise `flash` messages — used for sign-in errors; same pattern for notes form errors
- Rails `full_messages_for` / `errors.full_messages` — standard error rendering pattern

### Integration Points
- Nav bar in `app/views/layouts/application.html.erb` — "Notes" wordmark and sign-out link added here; applies globally
- `config/initializers/content_security_policy.rb` — existing file, uncomment and configure
- `config/environments/production.rb` — ActionMailer + HSTS config goes here
- `public/` — standalone HTML files (no Rails layout); must inline CSS or use a minimal style block

</code_context>

<specifics>
## Specific Ideas

- **Apple aesthetic**: Black-and-white palette. Clean horizontal nav bar with a bold "Notes" wordmark on the left. Table with subtle row borders, hover state (slight gray background), and clean typography. Buttons: primary actions use black fill + white text; secondary/destructive use white fill + black border.
- **Error pages**: Standalone `public/*.html` files — embed a minimal `<style>` block directly rather than referencing an external stylesheet (they're served by the web server when Rails is down).
- **DEPLOYMENT.md**: Should document sendmail (simplest for Linux VPS) and Gmail SMTP (common) as two concrete examples. Include the `RAILS_MASTER_KEY` env var requirement.
- **CSP and Turbo/Stimulus**: Turbo and Stimulus are served from the asset pipeline (importmap), so `script-src: :self` is sufficient. No `unsafe-inline` or nonces needed unless inline JS is added.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 3-polish-hardening*
*Context gathered: 2026-05-20*
