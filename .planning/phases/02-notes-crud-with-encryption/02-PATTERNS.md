# Phase 2: Notes CRUD with Encryption - Pattern Map

**Mapped:** 2026-05-18
**Files analyzed:** 9 new/modified files
**Analogs found:** 7 / 9

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `app/models/note.rb` | model | CRUD | `app/models/user.rb` | role-match |
| `app/controllers/notes_controller.rb` | controller | CRUD | `app/controllers/root_controller.rb` | role-match |
| `app/views/notes/index.html.erb` | view | request-response | `app/views/root/index.html.erb` | role-match |
| `app/views/notes/show.html.erb` | view | request-response | `app/views/root/index.html.erb` | role-match |
| `app/views/notes/new.html.erb` | view | request-response | `app/views/devise/sessions/new.html.erb` | role-match |
| `app/views/notes/edit.html.erb` | view | request-response | `app/views/devise/sessions/new.html.erb` | role-match |
| `app/views/notes/_form.html.erb` | view (partial) | request-response | `app/views/devise/shared/_error_messages.html.erb` | partial-match |
| `app/helpers/application_helper.rb` | helper/utility | transform | `app/helpers/application_helper.rb` | exact (modify) |
| `config/routes.rb` | config | request-response | `config/routes.rb` | exact (modify) |
| `app/models/user.rb` | model | CRUD | `app/models/user.rb` | exact (modify) |
| `Gemfile` | config | — | `Gemfile` | exact (modify) |
| `db/migrate/TIMESTAMP_create_notes.rb` | migration | CRUD | `db/migrate/20260518194239_devise_create_users.rb` | role-match |
| `test/models/note_test.rb` | test | CRUD | `test/models/user_test.rb` | role-match |
| `test/controllers/notes_controller_test.rb` | test | CRUD | `test/system/authentication_test.rb` | partial-match |
| `test/system/notes_test.rb` | test (system) | request-response | `test/system/authentication_test.rb` | role-match |
| `test/fixtures/notes.yml` | fixture | — | `test/fixtures/users.yml` | role-match |

---

## Pattern Assignments

### `app/models/note.rb` (model, CRUD)

**Analog:** `app/models/user.rb` (lines 1–3), `app/models/application_record.rb` (lines 1–3)

**Base class pattern** (`app/models/application_record.rb`, lines 1–3):
```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

**Model declaration pattern** (`app/models/user.rb`, lines 1–3):
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :validatable
end
```

**Core pattern to implement** — copy the class structure, then add:
```ruby
class Note < ApplicationRecord
  belongs_to :user
  has_one_attached :file, dependent: :purge   # D-07: synchronous purge
  encrypts :body                              # Active Record Encryption (D-03/D-05)

  # Derived title — not a stored column (CONTEXT specifics)
  def derived_title
    if body.present?
      body.lines.map(&:strip).find(&:present?)
    elsif file.attached?
      file.filename.to_s
    else
      "Untitled"
    end
  end
end
```

**Key decisions:**
- `encrypts :body` uses keys from Rails credentials under `active_record.encryption` (D-03)
- `dependent: :purge` on `has_one_attached` for synchronous purge on note deletion (D-07)
- No `dependent: :destroy` here — that goes on `User#has_many :notes` (see user.rb below)

---

### `app/controllers/notes_controller.rb` (controller, CRUD)

**Analog:** `app/controllers/root_controller.rb` (lines 1–5), `app/controllers/authenticated_controller.rb` (lines 1–3)

**Inheritance pattern** (`app/controllers/root_controller.rb`, lines 1–5):
```ruby
class RootController < AuthenticatedController
  def index
  end
end
```

**AuthenticatedController base** (`app/controllers/authenticated_controller.rb`, lines 1–3):
```ruby
class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
end
```

**Core pattern to implement** — full CRUD scoped through `current_user.notes` (D-09, D-10):
```ruby
class NotesController < AuthenticatedController
  before_action :set_note, only: %i[show edit update destroy]

  def index
    @notes = current_user.notes.order(created_at: :desc)
  end

  def show; end

  def new
    @note = current_user.notes.build
  end

  def edit; end

  def create
    @note = current_user.notes.build(note_params)
    if @note.save
      redirect_to @note, notice: "Note created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @note.update(note_params)
      redirect_to @note, notice: "Note updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path, notice: "Note deleted."
  end

  private

  def set_note
    # current_user.notes scoping — unknown note ID returns 404 (D-10)
    @note = current_user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:body, :file, :file_purge)
  end
end
```

**Scoping rule:** Always `current_user.notes.find(...)`, never `Note.find(...)` — prevents cross-user access (D-10).

---

### `app/views/notes/index.html.erb` (view, request-response)

**Analog:** `app/views/root/index.html.erb` (lines 1–2)

**Existing root view pattern** (`app/views/root/index.html.erb`, lines 1–2):
```erb
<p>Signed in as <%= current_user.email %></p>
<%= button_to "Sign out", destroy_user_session_path, method: :delete %>
```

**Layout wrapper** (`app/views/layouts/application.html.erb`, lines 1–29) — all views render inside this; no need to repeat `<html>` boilerplate.

**Core pattern to implement** — notes table (LIST-01 through LIST-03):
```erb
<h1>Notes</h1>
<%= link_to "New note", new_note_path %>

<% if @notes.any? %>
  <table>
    <thead>
      <tr>
        <th>Title</th>
        <th>Attachment</th>
        <th>Updated</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <% @notes.each do |note| %>
        <tr>
          <td><%= link_to note.derived_title, note %></td>
          <td><%= note.file.attached? ? note.file.filename : "" %></td>
          <td><%= note.updated_at.to_fs(:short) %></td>
          <td>
            <%= link_to "Edit", edit_note_path(note) %>
            <%= button_to "Delete", note, method: :delete,
                  data: { turbo_confirm: "Delete this note?" } %>
          </td>
        </tr>
      <% end %>
    </tbody>
  </table>
<% else %>
  <p>No notes yet.</p>
<% end %>
```

---

### `app/views/notes/show.html.erb` (view, request-response)

**Analog:** `app/views/root/index.html.erb`

**Core pattern to implement** — rendered markdown body + attachment link:
```erb
<h1><%= @note.derived_title %></h1>

<% if @note.body.present? %>
  <div class="note-body">
    <%= sanitize(render_markdown(@note.body),
          tags: %w[p h1 h2 h3 h4 h5 h6 ul ol li a code pre blockquote strong em br hr],
          attributes: %w[href]) %>
  </div>
<% end %>

<% if @note.file.attached? %>
  <p><%= link_to @note.file.filename, rails_blob_path(@note.file, disposition: "attachment") %></p>
<% end %>

<%= link_to "Edit", edit_note_path(@note) %>
<%= link_to "Back to notes", notes_path %>
```

---

### `app/views/notes/new.html.erb` (view, request-response)

**Analog:** `app/views/devise/sessions/new.html.erb` (lines 1–25) — shows `form_for`, field/actions structure, flash handling.

**Flash pattern** (`app/views/devise/sessions/new.html.erb`, lines 5–7):
```erb
<% if flash[:alert] %>
  <p class="sign-in-error"><%= flash[:alert] %></p>
<% end %>
```

**Form wrapper pattern** (`app/views/devise/sessions/new.html.erb`, lines 9–23):
```erb
<%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
  <div class="field">
    <%= f.label :email %>
    <%= f.email_field :email, autofocus: true, ... %>
  </div>
  <div class="actions">
    <%= f.submit "Sign in" %>
  </div>
<% end %>
```

**Core pattern to implement:**
```erb
<h1>New Note</h1>
<%= render "form", note: @note %>
<%= link_to "Back to notes", notes_path %>
```

---

### `app/views/notes/edit.html.erb` (view, request-response)

**Analog:** Same as `new.html.erb` above.

**Core pattern to implement:**
```erb
<h1>Edit Note</h1>
<%= render "form", note: @note %>
<%= link_to "Back", @note %>
```

---

### `app/views/notes/_form.html.erb` (view partial, request-response)

**Analog:** `app/views/devise/shared/_error_messages.html.erb` (lines 1–15) — validation error display; `app/views/devise/sessions/new.html.erb` — field/actions pattern.

**Error display pattern** (`app/views/devise/shared/_error_messages.html.erb`, lines 1–15):
```erb
<% if resource.errors.any? %>
  <div id="error_explanation" data-turbo-temporary>
    <h2><%= ... %></h2>
    <ul>
      <% resource.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

**Core pattern to implement** — covers D-06 (replace + remove attachment), D-08 (plain textarea):
```erb
<%= form_with model: note do |f| %>
  <% if note.errors.any? %>
    <div id="error_explanation">
      <ul>
        <% note.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= f.label :body, "Body (Markdown)" %>
    <%= f.text_area :body, rows: 12 %>
  </div>

  <% if note.file.attached? %>
    <p>Current attachment: <%= note.file.filename %></p>
    <div class="field">
      <%= f.label :file_purge, "Remove attachment" %>
      <%= f.check_box :file_purge %>
    </div>
  <% end %>

  <div class="field">
    <%= f.label :file, "Attach file" %>
    <%= f.file_field :file %>
  </div>

  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
```

**Note:** `f.check_box :file_purge` maps to `has_one_attached`'s built-in `file_purge=` writer. Permit `:file_purge` in `note_params`.

---

### `app/helpers/application_helper.rb` (helper/utility, transform)

**Analog:** `app/helpers/application_helper.rb` (lines 1–2) — currently empty module; this is an exact modify.

**Existing file** (`app/helpers/application_helper.rb`, lines 1–2):
```ruby
module ApplicationHelper
end
```

**Core pattern to implement** — add `render_markdown` (D-01, D-02):
```ruby
module ApplicationHelper
  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,    # sanitize happens in the view via sanitize()
      hard_wrap: false,
    )
    markdown = Redcarpet::Markdown.new(
      renderer,
      fenced_code_blocks: true,
      autolink: true,
      strikethrough: true,
      tables: true,
    )
    markdown.render(text).html_safe
  end
end
```

**Caller pattern in views** (sanitize wraps the output per D-02):
```erb
<%= sanitize(render_markdown(@note.body),
      tags: %w[p h1 h2 h3 h4 h5 h6 ul ol li a code pre blockquote strong em br hr],
      attributes: %w[href]) %>
```

---

### `config/routes.rb` (config, modify)

**Analog:** `config/routes.rb` (lines 1–13) — exact modify.

**Existing routes** (`config/routes.rb`, lines 1–13):
```ruby
Rails.application.routes.draw do
  devise_for :users

  root "root#index"

  get "up" => "rails/health#show", as: :rails_health_check
  # PWA routes commented out ...
end
```

**Core pattern to implement** — replace `root "root#index"` with notes, add resources:
```ruby
Rails.application.routes.draw do
  devise_for :users

  resources :notes
  root "notes#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
```

**Also:** `app/controllers/root_controller.rb` and `app/views/root/index.html.erb` are deleted in this phase.

---

### `app/models/user.rb` (model, modify)

**Analog:** `app/models/user.rb` (lines 1–3) — exact modify.

**Existing file** (`app/models/user.rb`, lines 1–3):
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :validatable
end
```

**Core pattern to implement** — add association:
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :validatable
  has_many :notes, dependent: :destroy
end
```

---

### `Gemfile` (config, modify)

**Analog:** `Gemfile` (lines 1–68) — exact modify.

**Existing gem block pattern** (`Gemfile`, lines 4–21) — gems listed flat in main group with inline comments:
```ruby
gem "rails", "~> 8.1.3"
gem "propshaft"
gem "sqlite3", ">= 2.1"
# ...
gem "devise"
```

**Core pattern to implement** — add after `devise` line:
```ruby
# Markdown rendering for note bodies
gem "redcarpet"
```

---

### `db/migrate/TIMESTAMP_create_notes.rb` (migration, CRUD)

**Analog:** `db/migrate/20260518194239_devise_create_users.rb` (lines 1–41)

**Migration class pattern** (`db/migrate/20260518194239_devise_create_users.rb`, lines 1–7):
```ruby
# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ""
      # ...
      t.timestamps null: false
    end
```

**Core pattern to implement:**
```ruby
# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body    # encrypted at the application layer via Active Record Encryption

      t.timestamps null: false
    end
  end
end
```

**Note:** `body` is `text` (not `string`) to avoid length limits for markdown content. Active Record Encryption stores ciphertext in the same column — no separate column needed. Active Storage attachment metadata is handled by the Active Storage tables (already installed).

---

### Test files

#### `test/models/note_test.rb` (model test)

**Analog:** `test/models/user_test.rb` (lines 1–7)

**Pattern** (`test/models/user_test.rb`, lines 1–7):
```ruby
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

**Core pattern to implement:**
```ruby
require "test_helper"

class NoteTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "noter@example.com", password: "password123")
  end

  test "derived_title returns first line of body when present" do
    note = @user.notes.build(body: "First line\nSecond line")
    assert_equal "First line", note.derived_title
  end

  test "derived_title returns filename when body is blank and file attached" do
    # attach a file and assert filename returned
  end

  test "derived_title returns Untitled when body blank and no file" do
    note = @user.notes.build(body: nil)
    assert_equal "Untitled", note.derived_title
  end

  test "note body is encrypted at rest" do
    note = @user.notes.create!(body: "secret content")
    raw = ActiveRecord::Base.connection.execute(
      "SELECT body FROM notes WHERE id = #{note.id}"
    ).first["body"]
    assert_not_equal "secret content", raw
  end
end
```

---

#### `test/system/notes_test.rb` (system test)

**Analog:** `test/system/authentication_test.rb` (lines 1–52)

**System test base pattern** (`test/system/authentication_test.rb`, lines 1–9):
```ruby
require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  def sign_in_as(email, password)
    visit new_user_session_path
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in"
  end
```

**Test assertion pattern** (`test/system/authentication_test.rb`, lines 11–16):
```ruby
  test "user with console-created credentials can sign in and lands on root" do
    User.create!(email: "user@example.com", password: "password123")
    sign_in_as "user@example.com", "password123"
    assert_text "Signed in as user@example.com"
    assert_equal root_path, current_path
  end
```

**Core pattern to implement:**
```ruby
require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  def sign_in_as(email, password)
    visit new_user_session_path
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in"
  end

  setup do
    @user = User.create!(email: "noter@example.com", password: "password123")
    sign_in_as "noter@example.com", "password123"
  end

  test "signed-in user sees empty notes list" do
    visit notes_path
    assert_text "No notes yet"
  end

  test "user can create a note and see it in the list" do
    visit new_note_path
    fill_in "Body", with: "# My Note\nBody text"
    click_button "Create Note"
    assert_text "My Note"  # derived_title
  end

  # ... edit, delete, isolation tests
end
```

---

#### `test/fixtures/notes.yml` (fixture)

**Analog:** `test/fixtures/users.yml` (lines 1–4)

**Pattern** (`test/fixtures/users.yml`, lines 1–4):
```yaml
# Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html

# No fixture users defined — system tests create users programmatically via User.create!
```

**Core pattern to implement** — keep fixture minimal, create records programmatically in tests:
```yaml
# Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html

# Note fixtures intentionally omitted — encryption requires valid Active Record Encryption
# config at fixture load time. Tests create notes programmatically via association.
```

---

## Shared Patterns

### Authentication Guard
**Source:** `app/controllers/authenticated_controller.rb`, lines 1–3
**Apply to:** `app/controllers/notes_controller.rb`
```ruby
class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
end
```
`NotesController < AuthenticatedController` inherits this automatically. Do not add a duplicate `before_action :authenticate_user!` in NotesController.

### Current User Scoping
**Source:** `app/controllers/root_controller.rb`, lines 1–5; Devise `current_user` helper
**Apply to:** All NotesController actions
```ruby
# Always scope through current_user.notes — never Note.find directly
@notes = current_user.notes.order(created_at: :desc)
@note  = current_user.notes.find(params[:id])  # raises ActiveRecord::RecordNotFound -> 404
```

### Layout Rendering
**Source:** `app/views/layouts/application.html.erb`, lines 1–29
**Apply to:** All notes views
Views need no `<html>` wrapper. Flash notices should be displayed; the layout's `<body>` only does `<%= yield %>` currently — either add flash rendering to the layout or display inline in each view. The latter matches the existing session view pattern (`flash[:alert]` inline).

### ERB Form Pattern
**Source:** `app/views/devise/sessions/new.html.erb`, lines 9–23
**Apply to:** `app/views/notes/new.html.erb`, `app/views/notes/edit.html.erb`, `app/views/notes/_form.html.erb`
Use `form_with model: note` (Rails 8 idiomatic) rather than `form_for`. Field wrappers use `<div class="field">`, submit in `<div class="actions">`.

### Turbo Delete Confirmation
**Source:** `app/views/root/index.html.erb` line 2 (`button_to` + `method: :delete`)
**Apply to:** Delete links in `app/views/notes/index.html.erb`
```erb
<%= button_to "Delete", note, method: :delete,
      data: { turbo_confirm: "Delete this note?" } %>
```

### Migration Style
**Source:** `db/migrate/20260518194239_devise_create_users.rb`, lines 1–2
**Apply to:** `db/migrate/TIMESTAMP_create_notes.rb`
```ruby
# frozen_string_literal: true
class CreateNotes < ActiveRecord::Migration[8.1]
```
Always include `# frozen_string_literal: true` header and pin to `Migration[8.1]`.

---

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `app/helpers/application_helper.rb` `render_markdown` method | utility | transform | No existing markdown/text processing helper in codebase; pattern comes from Redcarpet gem API |

---

## Metadata

**Analog search scope:** `app/controllers/`, `app/models/`, `app/views/`, `app/helpers/`, `config/`, `db/migrate/`, `test/`
**Files scanned:** 16
**Pattern extraction date:** 2026-05-18
