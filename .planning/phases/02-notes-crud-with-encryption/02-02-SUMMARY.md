---
plan: 02-02
phase: 02-notes-crud-with-encryption
status: complete
started: "2026-05-18"
completed: "2026-05-18"
key-files:
  created:
    - app/controllers/notes_controller.rb
    - app/views/notes/index.html.erb
    - app/views/notes/new.html.erb
    - app/views/notes/_form.html.erb
    - config/initializers/date_formats.rb
    - test/controllers/notes_controller_test.rb
    - test/fixtures/files/report.txt
  modified:
    - config/routes.rb
    - app/helpers/application_helper.rb
    - app/views/layouts/application.html.erb
    - app/assets/stylesheets/application.css
  deleted:
    - app/controllers/root_controller.rb
    - app/views/root/index.html.erb
requirements-covered:
  - NOTE-01
  - NOTE-02
  - NOTE-03
  - NOTE-06
  - NOTE-07
  - NOTE-10
  - LIST-01
  - LIST-02
  - LIST-03
  - SEC-01
---

## What Was Built

Delivered the first end-to-end vertical slice: a signed-in user can land on /notes, create a note with body and/or attachment, and see it listed with derived title.

- **Routes**: `resources :notes` + `root "notes#index"` replacing Phase 1 placeholder `root "root#index"`
- **NotesController** (`< AuthenticatedController`): index/new/create implemented; show/edit/update/destroy stubbed; all queries scoped through `current_user.notes`; `note_params` permits `:body, :file, :file_purge` only
- **RootController + root index view** deleted (Phase 1 placeholder fully retired)
- **`ApplicationHelper#render_markdown`**: Redcarpet renderer with fenced_code_blocks, autolink, strikethrough, tables — returns `html_safe` string (used by Plan 03 show view)
- **`config/initializers/date_formats.rb`**: `:short` format "May 18, 2025" for created/updated columns
- **Notes index view**: table with Title/Created/Updated/File columns, empty state "No notes yet", "New note" button
- **Notes new view**: back link + `h1 "New note"` + form partial
- **Form partial**: error block (id="error_explanation"), body textarea, conditional attachment fieldset (existing attachment + remove checkbox on edit, simple file input on new), submit "Create note"/"Update note" + Cancel link
- **Layout updated**: nav bar (sticky, 48px, "Notes" title + "Signed in as email" + sign-out button) inside `user_signed_in?` guard; flash region; `<main class="app-main">` wrapper; sign-out form uses `data-turbo: false` to prevent Turbo intercepting the DELETE and breaking redirect chain (auth system tests confirmed)
- **CSS**: nav layout, notes table, form fields, buttons, flash messages, error messages per UI-SPEC

## Test Results

```
18 runs, 34 assertions, 0 failures, 0 errors, 0 skips
```
(9 model tests + 9 controller integration tests)
Auth system tests: 5 runs, 15 assertions, 0 failures

## Deviations

- Tests written as **Rails integration tests** (ActionDispatch::IntegrationTest + Devise::Test::IntegrationHelpers) instead of Capybara system tests — faster, no browser overhead, user-directed preference
- `data-turbo: false` added to sign-out form — not in original plan but required because Turbo intercepts DELETE forms and the redirect chain stalls at `/`; auth tests confirm the fix works

## Self-Check: PASSED

All must_haves satisfied:
- ✓ Signed-in user visiting / sees notes index (empty state "No notes yet")
- ✓ User can create markdown note; derived title (first body line) appears in table
- ✓ File-only note: filename becomes title in table
- ✓ Empty form shows validation error "A note must have a body or an attachment."
- ✓ Unauthenticated /notes redirects to sign-in (integration test confirms)
- ✓ User A's index does not contain User B's notes (NOTE isolation)
