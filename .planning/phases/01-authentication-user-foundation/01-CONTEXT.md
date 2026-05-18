# Phase 1: Authentication & User Foundation - Context

**Gathered:** 2026-05-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver a working authentication layer: a user can sign in with email and password, maintain a session across browser refreshes, and sign out. Unauthenticated requests to protected routes are redirected to the sign-in page. Webmaster creates users via Rails console only — no self-registration UI exists anywhere in the app.

</domain>

<decisions>
## Implementation Decisions

### Auth Library
- **D-01:** Use **Devise** gem for authentication (not has_secure_password).
- **D-02:** Devise modules to enable: `:database_authenticatable`, `:validatable`, `:recoverable`. Do NOT include `:rememberable` — remove it entirely from the model and migration.
- **D-03:** User model fields: email + password only (what Devise requires). No display name, no extra columns.
- **D-04:** `:recoverable` is included in the model but the ActionMailer delivery is NOT configured in Phase 1. Webmaster resets passwords via Rails console for now. See Deferred section for the production requirement.

### Sign-in Page UX
- **D-05:** Sign-in page should be clean but presentable — a centered card/panel with a simple app title (e.g. "Notes"), email field, password field, and sign-in button. Not polished (Phase 3 owns polish), but not bare HTML either.
- **D-06:** Invalid credentials show a **generic** error message: "Invalid email or password." Do not distinguish between unknown email vs. wrong password.
- **D-07:** After successful sign-in, always redirect to the **notes list** (root/index). Do not implement store_location_for or redirect-back behavior.
- **D-08:** Generate Devise views with `rails generate devise:views` and customize the ERB templates rather than using gem defaults.

### Session Duration
- **D-09:** Standard Rails cookie session — session ends when the browser is closed. No persistent cookie.
- **D-10:** No idle timeout. Session lives until browser close.
- **D-11:** No "Remember me" checkbox. `:rememberable` is removed from the Devise model entirely (not just hidden in the UI).

### Access Control Architecture
- **D-12:** Create an `AuthenticatedController < ApplicationController` base controller that applies `before_action :authenticate_user!`. This is the **auth enforcement point** — not `ApplicationController`.
- **D-13:** All controllers that serve authenticated routes (e.g., `NotesController`) **MUST** subclass `AuthenticatedController`, not `ApplicationController` directly. This is an architectural invariant — the planner and executor must enforce it.
- **D-14:** The `/up` health check endpoint remains publicly accessible without authentication.
- **D-15:** Unauthenticated requests redirect to the Devise sign-in page (Devise default `authenticate_user!` behavior).

### Claude's Discretion
- Route organization (Devise route placement vs. custom session routes) — follow Devise conventions
- CSS styling details for the sign-in card — keep it minimal/clean, matching Phase 3 polish approach
- Exact Devise configuration options beyond the modules listed above

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Scope & Requirements
- `.planning/REQUIREMENTS.md` — AUTH-01 through AUTH-04, SEC-02 are the requirements for this phase; read before planning
- `.planning/ROADMAP.md` — Phase 1 goal, success criteria, and phase boundaries
- `.planning/PROJECT.md` — Core constraints (no self-registration, Active Record Encryption required, Rails 8.1 only)

### Codebase Foundation
- `app/controllers/application_controller.rb` — Base controller; `AuthenticatedController` must subclass this
- `config/routes.rb` — Current routes file (only `/up`); Devise routes added here
- `Gemfile` — Add Devise gem here

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ApplicationController` (`app/controllers/application_controller.rb`) — base controller with `allow_browser versions: :modern` and importmap etag invalidation; `AuthenticatedController` inherits from this
- `app/assets/stylesheets/application.css` — single CSS manifest; sign-in card styles added here
- `app/views/layouts/application.html.erb` — main layout; sign-in page will use this or a dedicated layout

### Established Patterns
- Standard Rails MVC — controllers, models, ERB views; no client-side framework
- Turbo Drive — navigation intercepts page loads; sign-in form submits work naturally with Turbo
- Importmap + Stimulus — JS behavior via stimulus controllers if needed; no bundler required

### Integration Points
- `config/routes.rb` — Devise routes (`devise_for :users`) added here; root route set to notes list after auth is in place
- The `AuthenticatedController` is the integration point all future feature controllers connect to

</code_context>

<specifics>
## Specific Ideas

- **AuthenticatedController pattern**: User explicitly requested an intermediate base controller (`AuthenticatedController < ApplicationController`) rather than `before_action :authenticate_user!` in `ApplicationController`. This is an architectural invariant — every secured controller subclasses `AuthenticatedController`.
- **Devise modules exactly**: `:database_authenticatable`, `:validatable`, `:recoverable` — no others.`:rememberable` removed entirely (not just hidden).
- **Sign-in page**: Clean centered card, simple title, generic error messages only.

</specifics>

<deferred>
## Deferred Ideas

### Mailer Setup for Password Recovery (PRODUCTION PREREQUISITE — must be documented)
`:recoverable` is installed but ActionMailer delivery is NOT configured in Phase 1. Before the app is deployed to production, the following MUST be set up and documented for both humans and AI agents:
- Configure ActionMailer delivery method (SMTP, SendGrid, Postmark, etc.)
- Set `config.action_mailer.default_url_options` per environment
- Test the "Forgot password" flow end-to-end
- This belongs in Phase 3 (Polish & Hardening) or a dedicated deployment/ops phase.

</deferred>

---

*Phase: 1-authentication-user-foundation*
*Context gathered: 2026-05-18*
