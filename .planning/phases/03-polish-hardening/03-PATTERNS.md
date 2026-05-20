# Phase 3: Polish & Hardening - Pattern Map

**Mapped:** 2026-05-20
**Files analyzed:** 10 new/modified files
**Analogs found:** 9 / 10

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `app/assets/stylesheets/application.css` | config/style | transform | itself (extend) | exact |
| `app/views/layouts/application.html.erb` | view/layout | request-response | itself (modify) | exact |
| `app/views/notes/index.html.erb` | view | request-response | itself (restyle) | exact |
| `app/views/notes/show.html.erb` | view | request-response | itself (restyle) | exact |
| `app/views/notes/_form.html.erb` | view/partial | request-response | itself (restyle) | exact |
| `config/initializers/content_security_policy.rb` | config | request-response | itself (uncomment) | exact |
| `config/environments/production.rb` | config | - | itself (annotate) | exact |
| `public/404.html` (+ 422, 500) | view/static | - | itself (restyle) | exact |
| `config/deploy.yml` | config | - | itself (audit) | exact |
| `DEPLOYMENT.md` | documentation | - | none | no analog |

## Pattern Assignments

### `app/assets/stylesheets/application.css` (extend existing)

**Analog:** itself — already contains the full design system.

**Existing design token pattern** (lines 12-19):
```css
body {
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  font-size: 16px;
  color: #111827;
  margin: 0;
  padding: 0;
}
```

**Existing button pattern** (lines 271-301):
```css
.btn-primary {
  display: inline-flex;
  align-items: center;
  background: #2563eb;
  color: #ffffff;
  border: none;
  border-radius: 6px;
  height: 36px;
  padding: 0 16px;
  font-size: 14px;
  font-weight: 400;
  text-decoration: none;
  cursor: pointer;
}
```

**Decision D-UI-01 requires black-and-white only.** The existing CSS uses blue (`#2563eb`) for primary actions and focus outlines — these must be replaced with black (`#111827` / `#000`) throughout. The sign-in card pattern (`.sign-in-card`, lines 30-38) establishes the card/border style to replicate for all new UI regions.

**Error state pattern** (lines 323-331 — already exists, needs field-level companion):
```css
#error_explanation {
  margin-bottom: 16px;
}
.error-message {
  font-size: 14px;
  color: #dc2626;
  margin: 4px 0;
}
```
Add `.field--error input`, `.field--error textarea` with `border-color: #dc2626` to match D-ERR-01.

**Additions required (black-and-white aesthetic per D-UI-01/D-UI-06):**
- Replace `#2563eb` with `#111827` (or `#000`) in `.btn-primary`, `.actions input[type="submit"]`, `.field input:focus`, `.field textarea:focus`, all `link-accent` / `link-muted` color overrides.
- Add `.btn-icon` for small edit/delete icon buttons in the table last column (D-UI-02).
- Add `.note-show-header` flex container for top-right action bar (D-UI-04).

---

### `app/views/layouts/application.html.erb` (modify nav)

**Analog:** itself — already implements the nav bar skeleton.

**Existing nav pattern** (lines 27-35):
```erb
<% if user_signed_in? %>
  <nav class="app-nav">
    <span class="app-nav-title">Notes</span>
    <div class="app-nav-right">
      <span class="app-nav-user">Signed in as <%= current_user.email %></span>
      <%= button_to "Sign out", destroy_user_session_path, method: :delete,
            form: { class: "nav-signout", data: { turbo: false } } %>
    </div>
  </nav>
<% end %>
```

D-UI-05 is already satisfied: "Notes" wordmark left-aligned, sign-out right-aligned. Nav needs only CSS color changes (blue focus ring to black) if any interactive elements are in the nav.

**Flash pattern** (lines 37-39):
```erb
<% flash.each do |type, msg| %>
  <p class="flash flash-<%= type %>"><%= msg %></p>
<% end %>
```
Flash classes `.flash-notice` / `.flash-alert` already defined. No structural change needed.

---

### `app/views/notes/index.html.erb` (restyle table + actions column)

**Analog:** itself — existing table needs an actions column replacing the file indicator column.

**Existing row pattern** (lines 17-29):
```erb
<% @notes.each do |note| %>
  <tr>
    <td><%= link_to note.derived_title, note %></td>
    <td><%= l(note.created_at, format: :short) %></td>
    <td><%= l(note.updated_at, format: :short) %></td>
    <td>
      <% if note.file.attached? %>
        <span aria-label="Has attachment">●</span>
      <% end %>
    </td>
  </tr>
<% end %>
```

D-UI-02 requires:
- Row click navigates to show page — wrap `<tr>` in a clickable style or use `data-href` + Stimulus, OR make the title cell fill the row visually and add a transparent overlay anchor.
- Last column becomes edit/delete icon buttons, not file indicator (file indicator can move to title cell or be dropped).
- Delete button uses `button_to` with `method: :delete, data: { turbo_confirm: "..." }` — copy pattern from `show.html.erb` line 25-28.

**Existing delete button pattern from show.html.erb** (lines 25-28):
```erb
<%= button_to "Delete note", @note, method: :delete,
      data: { turbo_confirm: "Delete this note? This cannot be undone." },
      class: "btn-destructive",
      form: { data: { turbo: false } } %>
```
Adapt for the table: substitute the link variable per-row note object.

---

### `app/views/notes/show.html.erb` (add top-right action bar)

**Analog:** itself.

**Existing action pattern** (lines 23-29 — bottom of page):
```erb
<div class="note-actions">
  <%= link_to "Edit", edit_note_path(@note), class: "link-accent" %>
  <%= button_to "Delete note", @note, method: :delete,
        data: { turbo_confirm: "Delete this note? This cannot be undone." },
        class: "btn-destructive",
        form: { data: { turbo: false } } %>
</div>
```

D-UI-04 requires Edit and Delete to move to a top-right action bar (not the bottom). Use `.page-header` flex pattern from `index.html.erb` (title left, actions right) to place a `<div class="note-show-actions">` at the top alongside the `<h1>`.

---

### `app/views/notes/_form.html.erb` (validation error UX)

**Analog:** itself — error block already exists at lines 2-8.

**Existing error summary pattern** (lines 2-8):
```erb
<% if note.errors.any? %>
  <div id="error_explanation">
    <% note.errors.full_messages.each do |msg| %>
      <p class="error-message"><%= msg %></p>
    <% end %>
  </div>
<% end %>
```

D-ERR-01 requires adding per-field inline error state. Pattern to add alongside each field:
```erb
<div class="field <%= 'field--error' if note.errors[:body].any? %>">
  <%= f.label :body, "Body (Markdown)" %>
  <%= f.text_area :body, rows: 12 %>
  <% note.errors[:body].each do |msg| %>
    <p class="error-message"><%= msg %></p>
  <% end %>
</div>
```
CSS `.field--error input, .field--error textarea { border-color: #dc2626; }` added to application.css.

D-UI-03 requires the body label/placeholder to say "Write your note in markdown" — update `f.label` text and add `placeholder:` to `f.text_area`.

---

### `config/initializers/content_security_policy.rb` (uncomment and configure)

**Analog:** itself — the entire file is commented out, lines 1-29.

**Commented template to adapt** (lines 7-17):
```ruby
# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#   end
# end
```

D-SEC-01 policy (no `unsafe-inline`, no `eval`, `script-src :self` sufficient for importmap):
```ruby
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self
    policy.connect_src :self
  end
end
```
Do NOT enable `content_security_policy_nonce_generator` — Turbo/Stimulus are served via importmap from `:self`, so nonces are not needed.

---

### `config/environments/production.rb` (add comments + HSTS)

**Analog:** itself.

**Existing HSTS/SSL comment block** (lines 30-34):
```ruby
# Assume all access to the app is happening through a SSL-terminating reverse proxy.
# config.assume_ssl = true

# Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
# config.force_ssl = true
```

D-SEC-03 HSTS: Uncomment `config.force_ssl = true` or add inline comment explaining it enables HSTS. Add `X-Frame-Options` and `X-Content-Type-Options` via a Rack middleware initializer (see shared patterns below) rather than here.

D-MAIL-02 mailer comment addition — existing block at lines 64-71 already has the SMTP template. Add sendmail example as commented alternative:
```ruby
# --- Sendmail (Linux VPS default) ---
# config.action_mailer.delivery_method = :sendmail
# config.action_mailer.sendmail_settings = { location: "/usr/sbin/sendmail", arguments: "-i" }
```

---

### `public/404.html`, `public/422.html`, `public/500.html` (restyle)

**Analog:** `public/404.html` — all three follow the same standalone HTML pattern with inline `<style>`.

**Existing inline style pattern** (lines 13-116 of 404.html): Each file has a self-contained `<style>` block and a `<main>` centered layout. The SVG graphic is decorative and can be replaced.

D-SEC-02 target style — minimal centered message, app name, matching design system:
```html
<style>
  * { box-sizing: border-box; margin: 0; }
  body {
    font-family: system-ui, -apple-system, sans-serif;
    background: #fff;
    color: #111827;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100dvh;
  }
  main { text-align: center; padding: 2rem; }
  h1 { font-size: 2rem; font-weight: 700; margin-bottom: 0.5rem; }
  p  { font-size: 1rem; color: #6b7280; }
  a  { color: #111827; font-weight: 600; }
</style>
```
Each page keeps its own `<title>` and unique `<h1>` + `<p>` message. No external stylesheet reference (files must work when Rails is down).

---

### `config/deploy.yml` (audit — read-only)

**Issues found:**
- `servers.web`: `192.168.0.1` is a placeholder — must be replaced with actual server IP.
- `registry.server`: `localhost:5555` is a placeholder — must be replaced with real registry (Docker Hub, GHCR, DO Registry, etc.).
- `registry.username` and `registry.password` are commented out — must be filled for authenticated registries.
- `config.assume_ssl` / `config.force_ssl` in `production.rb` must be enabled when using the `proxy.ssl` option.
- Storage volume `gsd_notes_app_storage:/rails/storage` is correct for SQLite + Active Storage.

Document these gaps in `DEPLOYMENT.md` (D-DEPLOY-01 / D-DEPLOY-02).

---

## Shared Patterns

### HTTP Security Headers (D-SEC-03)
**Approach:** New initializer `config/initializers/security_headers.rb` using Rails middleware.
**Pattern to follow** (Rails Rack middleware insert):
```ruby
# config/initializers/security_headers.rb
Rails.application.config.action_dispatch.default_headers.merge!(
  "X-Frame-Options"        => "SAMEORIGIN",
  "X-Content-Type-Options" => "nosniff"
)
```
HSTS is handled by `config.force_ssl = true` in `production.rb` (Rails sets the header automatically).

**Apply to:** all requests via the middleware stack — no per-controller changes needed.

### Turbo Delete Confirmation
**Source:** `app/views/notes/show.html.erb` lines 25-28
**Apply to:** notes index table actions column (delete per row)
```erb
<%= button_to "Delete", note, method: :delete,
      data: { turbo_confirm: "Delete this note? This cannot be undone." },
      class: "btn-icon btn-icon--danger",
      form: { data: { turbo: false } } %>
```

### Test Pattern for Security/Config Changes
**Source:** `test/controllers/notes_controller_test.rb` lines 1-15
```ruby
require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "...", password: "password123")
  end

  teardown do
    @user.destroy
  end
```
New tests for HTTP headers should be integration tests asserting `response.headers["X-Frame-Options"]` etc. New system tests for UI polish should use Capybara + Selenium (see `test/system/` if it exists).

---

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `DEPLOYMENT.md` | documentation | - | No deployment docs exist in the repo; RESEARCH.md patterns + deploy.yml audit are the only inputs |

---

## Metadata

**Analog search scope:** `app/`, `config/`, `public/`, `test/`
**Files scanned:** 15
**Pattern extraction date:** 2026-05-20
