# Phase 1: Authentication & User Foundation - Pattern Map

**Mapped:** 2026-05-18
**Files analyzed:** 8 new/modified files
**Analogs found:** 5 / 8 (3 files have no close codebase analog — use Devise conventions)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `Gemfile` | config | — | `Gemfile` (existing) | exact — modify in place |
| `config/routes.rb` | config | request-response | `config/routes.rb` (existing) | exact — modify in place |
| `app/models/user.rb` | model | CRUD | `app/models/application_record.rb` | partial — same base class, different content |
| `db/migrate/YYYYMMDDHHMMSS_devise_create_users.rb` | migration | — | none — Devise generator output | no analog |
| `app/controllers/application_controller.rb` | controller | request-response | `app/controllers/application_controller.rb` (existing) | exact — read-only reference, do not modify |
| `app/controllers/authenticated_controller.rb` | controller | request-response | `app/controllers/application_controller.rb` | role-match — same inheritance pattern |
| `app/views/devise/sessions/new.html.erb` | view | request-response | `app/views/layouts/application.html.erb` | partial — ERB conventions, layout context |
| `app/assets/stylesheets/application.css` | config/style | — | `app/assets/stylesheets/application.css` (existing) | exact — modify in place |

---

## Pattern Assignments

### `Gemfile` (config — modify in place)

**Analog:** `Gemfile` lines 1–67 (existing file, full content already read)

**Insertion pattern** — add Devise after the existing gem declarations, before the `group :development, :test` block. Match the existing comment style:

```ruby
# Use Devise for authentication [https://github.com/heartcombo/devise]
gem "devise"
```

**Also required** — bcrypt is Devise's dependency for `database_authenticatable`. The existing `Gemfile` has bcrypt commented out (line 22). Uncomment it:

```ruby
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"
```

---

### `config/routes.rb` (config — modify in place)

**Analog:** `config/routes.rb` lines 1–14 (existing file, full content already read)

**Existing pattern** (lines 1–14):
```ruby
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  # root "posts#index"
end
```

**Insertion pattern** — add Devise routes and root route inside the existing `draw` block, preserving the health check:

```ruby
Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  # Authenticated root — notes list (NotesController defined in Phase 2)
  # root "notes#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
```

Notes:
- `skip: [:registrations]` removes the self-registration routes (enforces D-04 / no self-registration).
- The root route is commented until `NotesController` exists (Phase 2). The planner must decide whether to leave it commented or point it to a placeholder in Phase 1.
- Health check `/up` remains publicly accessible (D-14).

---

### `app/models/user.rb` (model, CRUD)

**Analog:** `app/models/application_record.rb` (lines 1–3)

**Base class pattern** (lines 1–3):
```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

**Model pattern for User** — inherits from `ApplicationRecord`, includes only the three approved Devise modules (D-02). `:rememberable` is NOT included:

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :validatable
end
```

Key rules:
- No `devise :registerable` — self-registration is disabled (D-04).
- No `devise :rememberable` — removed entirely, not just hidden (D-11).
- No extra columns beyond what Devise requires for the three modules.
- Double-quoted strings per Omakase style.

---

### `db/migrate/YYYYMMDDHHMMSS_devise_create_users.rb` (migration)

**Analog:** None in codebase. Use Devise generator output as the base.

**Generator command:**
```
rails generate devise User
```

**Post-generation required edits** — after generating, remove the `rememberable` block from the migration. The generated migration will include a section like:

```ruby
## Rememberable
t.datetime :remember_created_at
```

This entire block must be deleted from the migration file to match D-11 (`:rememberable` removed entirely, not just hidden).

The migration output by the generator is the canonical source. No codebase analog exists.

---

### `app/controllers/application_controller.rb` (controller — reference only, do NOT modify)

**This file is a read-only reference.** `AuthenticatedController` inherits from it.

**Existing content** (lines 1–7):
```ruby
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
```

`AuthenticatedController` must call `super` implicitly via inheritance — it does NOT re-declare `allow_browser` or `stale_when_importmap_changes`. Those are inherited automatically.

---

### `app/controllers/authenticated_controller.rb` (controller, request-response)

**Analog:** `app/controllers/application_controller.rb` lines 1–7

**Inheritance pattern** — matches the style of all `Application*` base classes in this codebase (compact, minimal, single-responsibility):

```ruby
class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
end
```

This is the complete file. No other logic belongs here in Phase 1. All controllers serving authenticated routes (Phase 2+) subclass `AuthenticatedController`, never `ApplicationController` directly (D-12, D-13).

**Style notes:**
- No `frozen_string_literal` magic comment — not enforced by Omakase defaults.
- Double-quoted strings if strings are needed (none here).
- Two-space indentation.

---

### `app/views/devise/sessions/new.html.erb` (view, request-response)

**Analog:** `app/views/layouts/application.html.erb` lines 1–29 (ERB conventions)

**Layout conventions from** `app/views/layouts/application.html.erb`:
```erb
<title><%= content_for(:title) || "Gsd Notes App" %></title>
<%= csrf_meta_tags %>
<%= csp_meta_tag %>
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
<%= javascript_importmap_tags %>
```

**Sign-in view pattern** — Devise generates a baseline `new.html.erb` via `rails generate devise:views` (D-08). The generated file is then customized. The customized result should follow this structure:

```erb
<div class="sign-in-container">
  <div class="sign-in-card">
    <h1 class="sign-in-title">Notes</h1>

    <% if flash[:alert] %>
      <p class="sign-in-error"><%= flash[:alert] %></p>
    <% end %>

    <%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
      <div class="field">
        <%= f.label :email %>
        <%= f.email_field :email, autofocus: true, autocomplete: "email" %>
      </div>

      <div class="field">
        <%= f.label :password %>
        <%= f.password_field :password, autocomplete: "current-password" %>
      </div>

      <div class="actions">
        <%= f.submit "Sign in" %>
      </div>
    <% end %>

    <%= render "devise/shared/links" %>
  </div>
</div>
```

Key rules:
- No "Remember me" checkbox — `:rememberable` is removed (D-11).
- No registration link — no self-registration (CLAUDE.md constraint). The `devise/shared/links` partial may render a "Sign up" link if `:registerable` routes exist; since routes skip registrations, that link will not appear. Verify after generation.
- Error message display via `flash[:alert]` — Devise writes the generic "Invalid Email or Password." message into `flash[:alert]` by default, satisfying D-06.
- After sign-in, Devise redirects to `root_path` by default. Override `after_sign_in_path_for` in `ApplicationController` if root is not yet set in Phase 1, or configure `root "notes#index"` once Phase 2 is complete (D-07).

---

### `app/assets/stylesheets/application.css` (config/style — modify in place)

**Analog:** `app/assets/stylesheets/application.css` lines 1–11 (existing file, full content already read)

**Existing manifest comment pattern** (lines 1–11):
```css
/*
 * This is a manifest file that'll be compiled into application.css.
 * ...
 */
```

**Addition pattern** — append sign-in card styles after the manifest comment block. Keep it minimal per D-05 (clean but not polished — Phase 3 owns polish):

```css
/* Sign-in page */
.sign-in-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f5f5f5;
}

.sign-in-card {
  background: #fff;
  padding: 2rem;
  border-radius: 6px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
  width: 100%;
  max-width: 380px;
}

.sign-in-title {
  margin: 0 0 1.5rem;
  font-size: 1.5rem;
  text-align: center;
}

.sign-in-error {
  color: #c0392b;
  margin-bottom: 1rem;
}

.field {
  margin-bottom: 1rem;
}

.field label {
  display: block;
  margin-bottom: 0.25rem;
  font-size: 0.875rem;
}

.field input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
}

.actions input[type="submit"] {
  width: 100%;
  padding: 0.625rem;
  background: #333;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}
```

---

## Shared Patterns

### Controller Base Class Inheritance
**Source:** `app/controllers/application_controller.rb` lines 1–7
**Apply to:** `app/controllers/authenticated_controller.rb` and all future feature controllers
```ruby
# Pattern: each controller is a single-responsibility class that subclasses its parent.
# ApplicationController   → ActionController::Base  (framework hook point)
# AuthenticatedController → ApplicationController   (auth enforcement point)
# NotesController         → AuthenticatedController (feature controller — Phase 2)
```

### Model Base Class Inheritance
**Source:** `app/models/application_record.rb` lines 1–3
**Apply to:** `app/models/user.rb` and all future models
```ruby
class SomeModel < ApplicationRecord
  # ActiveRecord features + AR Encryption available here
end
```

### ERB View Conventions
**Source:** `app/views/layouts/application.html.erb` lines 1–29
**Apply to:** `app/views/devise/sessions/new.html.erb` and all future ERB views
- Use `<%= %>` for output, `<% %>` for logic.
- Two-space indentation inside ERB tags.
- `csrf_meta_tags` and `csp_meta_tag` are in the layout — views do not need to repeat them.
- Flash messages rendered inside the view body, not the layout (layout has no flash rendering currently).

### Devise `after_sign_in_path_for` Override
**Source:** No existing analog — Devise convention.
**Apply to:** `app/controllers/application_controller.rb` OR a Devise-specific concern.
**Pattern** (add to `ApplicationController` if a fixed redirect is needed before root route is set):
```ruby
def after_sign_in_path_for(resource)
  root_path
end
```
Per D-07, always redirect to notes list (root). This can be deferred until Phase 2 sets `root "notes#index"`.

---

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `db/migrate/YYYYMMDDHHMMSS_devise_create_users.rb` | migration | — | No migrations exist in codebase yet; Devise generator is the source |
| `config/initializers/devise.rb` | config | — | No initializers other than standard Rails ones exist; Devise generator creates this file |
| `app/views/devise/**` (all generated views) | view | request-response | No feature views exist yet; `rails generate devise:views` is the source |

---

## Metadata

**Analog search scope:** `app/controllers/`, `app/models/`, `app/views/`, `config/`, `Gemfile`, `db/`
**Files scanned:** 20
**Pattern extraction date:** 2026-05-18

### Codebase State Note
This is a fresh Rails 8.1 skeleton. Only base/abstract classes exist (`ApplicationController`, `ApplicationRecord`, `ApplicationJob`, `ApplicationMailer`). There are no feature controllers, models, migrations, or views to draw from. The analog patterns are therefore derived from:
1. The abstract base classes for inheritance structure.
2. The layout ERB for view conventions.
3. Devise generator output as the canonical source for migration and initializer files.
