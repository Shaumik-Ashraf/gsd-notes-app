# Phase 2: Notes CRUD with Encryption - Context

**Gathered:** 2026-05-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver full notes lifecycle for authenticated users: create, list, view, edit, and delete notes. Each note has an optional markdown body and/or a single file attachment. The note body is encrypted at rest using Active Record Encryption. A derived title is computed from the first line of the body, or falls back to the attachment filename when body is absent. Notes are displayed in a table. A user sees only their own notes.

</domain>

<decisions>
## Implementation Decisions

### Markdown Rendering
- **D-01:** Use the **Redcarpet** gem for rendering note body markdown to HTML. Add `gem "redcarpet"` to the Gemfile.
- **D-02:** Sanitize rendered HTML using **Rails built-in `ActionView::Helpers::SanitizeHelper#sanitize`** (no extra gems). Allowlist should cover standard markdown output: `p`, `h1`–`h6`, `ul`, `ol`, `li`, `a`, `code`, `pre`, `blockquote`, `strong`, `em`, `br`, `hr`. This is applied before rendering the HTML in views via `sanitize(render_markdown(body), ...)`.

### Encryption Key Setup
- **D-03:** Active Record Encryption keys (`primary_key`, `deterministic_key`, `key_derivation_salt`) are stored in **Rails credentials** (`config/credentials.yml.enc`), encrypted with `RAILS_MASTER_KEY`.
- **D-04:** Keys are generated once using `rails db:encryption:init`. The one-time setup step MUST be documented in `CLAUDE.md` (or a `SETUP.md`) for both humans and AI agents. Downstream agents that run `rails db:migrate` or start the server must be aware that encryption keys must exist in credentials first.
- **D-05:** In development, the default Rails `master.key` / `credentials.yml.enc` pattern is used. No separate `.env` or hardcoded dev keys.

### Attachment Edit Behavior
- **D-06:** The edit form must support **both** (a) uploading a new file to replace the existing attachment, and (b) checking a "Remove attachment" checkbox to remove the existing attachment without adding a replacement. Both operations must leave the note in a valid state (body-only is valid per NOTE-10).
- **D-07:** When a note is deleted, its Active Storage attachment is purged **synchronously** using `dependent: :purge` on `has_one_attached`. No async job — keeps test isolation simple and is appropriate for v1 scale.

### Body Editor UX
- **D-08:** Note body uses a plain `<textarea>` in the create and edit forms. No JS markdown editor widget in Phase 2. The user writes raw markdown; the rendered output is shown on the note show page. Phase 3 can revisit adding a richer editor.

### Access Control (carried from Phase 1)
- **D-09:** `NotesController` MUST subclass `AuthenticatedController`, not `ApplicationController` directly. This is an architectural invariant from Phase 1 (D-13 in 01-CONTEXT.md).
- **D-10:** Note scoping: all NotesController actions must scope queries through `current_user.notes` (or equivalent association). Direct URL access to another user's note returns 404 (not 403) to avoid confirming existence.

### Claude's Discretion
- Exact Redcarpet render options (`:fenced_code_blocks`, `:autolink`, etc.) — use sensible defaults for a notes app
- CSS styling for the notes table and note forms — keep it clean but unstyled (Phase 3 owns polish)
- Exact column types and migration details (string vs text for body, etc.)
- Helper method name and location for the markdown rendering utility (e.g., `ApplicationHelper#render_markdown`)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Scope & Requirements
- `.planning/REQUIREMENTS.md` — NOTE-01 through NOTE-10, LIST-01 through LIST-03, SEC-01 are the requirements for this phase; MUST be read before planning
- `.planning/ROADMAP.md` — Phase 2 goal, success criteria, and phase boundaries
- `.planning/PROJECT.md` — Core constraints (Active Record Encryption non-negotiable, Rails 8.1 only, no self-registration)

### Phase 1 Decisions (architectural invariants that apply here)
- `.planning/phases/01-authentication-user-foundation/01-CONTEXT.md` — Especially D-12 through D-15: AuthenticatedController pattern, `:authenticate_user!` enforcement point, health check stays public

### Codebase Foundation
- `app/controllers/authenticated_controller.rb` — Base for NotesController (MUST subclass this, not ApplicationController)
- `app/controllers/root_controller.rb` — Phase 1 placeholder; Phase 2 replaces routing from `root "root#index"` to `root "notes#index"` and removes RootController
- `config/routes.rb` — Add `resources :notes` here; update root route
- `Gemfile` — Add `gem "redcarpet"` here
- `config/credentials.yml.enc` — Encryption keys live here (generated via `rails db:encryption:init`)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AuthenticatedController` (`app/controllers/authenticated_controller.rb`) — `NotesController` inherits from this; `before_action :authenticate_user!` is inherited automatically
- `app/assets/stylesheets/application.css` — All CSS for notes table, forms, and show page goes here
- `app/views/layouts/application.html.erb` — Notes views will render inside this layout

### Established Patterns
- Standard Rails MVC — controllers, models, ERB views; no client-side framework
- Turbo Drive — form submissions and page navigation work with Turbo; no `data-turbo: false` needed for standard CRUD
- Importmap + Stimulus — available if needed (e.g., confirm-on-delete), but plain Rails `confirm:` data attribute is sufficient for delete confirmation
- Devise `current_user` helper — available in all controllers inheriting ApplicationController; use `current_user.notes` to scope queries

### Integration Points
- `config/routes.rb` — `resources :notes` added here; `root "notes#index"` replaces `root "root#index"`
- `app/models/user.rb` — Add `has_many :notes, dependent: :destroy` association here
- Active Storage — already bundled with Rails 8.1; `has_one_attached :file` on Note model; no extra setup beyond running `rails active_storage:install` if not already run

</code_context>

<specifics>
## Specific Ideas

- **Title derivation**: Computed method `Note#derived_title` (or similar) — first non-blank line of body when body is present, otherwise the attached file's filename. This is a model method, not a stored column.
- **Attachment "Remove" checkbox**: Use a hidden field pattern with a `_purge` suffix (e.g., `file_purge: "1"`) — Rails Active Storage supports `has_one_attached` with a `_purge` writer. The edit form includes a checkbox wired to this param.
- **Encryption setup step documentation**: The plan for this phase must include a setup step: `rails db:encryption:init` → paste output into `rails credentials:edit` under `active_record.encryption`. This step MUST run before `rails db:migrate` or the server boot will fail with missing encryption config.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 2-notes-crud-with-encryption*
*Context gathered: 2026-05-18*
