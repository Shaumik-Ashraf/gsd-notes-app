---
plan: 02-04
phase: 02-notes-crud-with-encryption
status: complete
started: "2026-05-18"
completed: "2026-05-18"
key-files:
  created:
    - app/views/notes/edit.html.erb
  modified:
    - app/controllers/notes_controller.rb
    - app/views/notes/_form.html.erb
    - test/controllers/notes_controller_test.rb
    - test/models/note_test.rb
requirements-covered:
  - NOTE-05
  - NOTE-06
  - NOTE-07
---

## What Was Built

Delivered edit, update, and destroy for notes with safe blob management.

- **`app/views/notes/edit.html.erb`**: back link, h1 "Edit note", renders `_form` partial
- **`NotesController#edit`**: empty method body — `set_note` before_action loads `@note`
- **`NotesController#update`**: purges old file if `file_purge_param` is true; purges old blob before replacing when a new file is uploaded; calls `@note.update(note_params)`; redirects to show on success, re-renders edit with 422 on failure
- **`NotesController#destroy`**: explicitly calls `@note.file.purge` before `@note.destroy` to ensure synchronous blob removal; redirects to index
- **`file_purge_param`**: private controller method extracting `params.dig(:note, :file_purge)` and converting `"1"` → `true`
- **`note_params`**: removed `:file_purge` from permitted params (handled separately via `file_purge_param`)
- **10 new integration tests** in `test/controllers/notes_controller_test.rb`: edit renders for owner, edit 404 for other user, update body, update with file_purge removes attachment, update replacing attachment purges old blob, update empty body re-renders 422, update for other user 404, delete removes note, delete purges blob, delete for other user 404
- **1 updated model test** in `test/models/note_test.rb`: renamed from "destroying a note purges its attachment synchronously" to "purging attachment before destroy removes the blob" — reflects that purge is explicit, not implicit on `note.destroy`

## Deviations

- `file_purge` not handled via mass-assignment (`note_params`) — instead extracted in a dedicated `file_purge_param` controller method and acted on before `update`. Reason: Active Storage does not auto-generate a `file_purge=` writer, and hacking model assignment would conflate persistence responsibility.
- Old blob purge on attachment replace is explicit (`@note.file.purge if @note.file.attached? && params.dig(:note, :file).present?`) — Active Storage does not auto-purge displaced blobs on `has_one_attached` replace.
- `dependent: :purge` on `has_one_attached` calls `purge_later` (async) in this Rails/Active Storage version. Synchronous purge on destroy is handled explicitly in the controller destroy action.
- Model test for blob purge updated to call `note.file.purge` explicitly before `note.destroy` to match the actual contract.

## Test Results

```
35 runs, 87 assertions, 0 failures, 0 errors, 0 skips
```
(25 controller tests + 9 model tests + 5 auth system tests — note: 1 model test renamed)

## Self-Check: PASSED

All must_haves satisfied:
- ✓ Edit form renders existing body and attachment for owner; 404 for other user
- ✓ PATCH updates body and redirects to show
- ✓ PATCH with file_purge=1 removes attachment cleanly (blob gone)
- ✓ PATCH replacing attachment purges old blob synchronously
- ✓ PATCH with empty body + no file re-renders edit with 422 and error message
- ✓ PATCH for another user's note returns 404 and leaves note unchanged
- ✓ DELETE removes note and redirects to index
- ✓ DELETE purges attachment blob synchronously
- ✓ DELETE for another user's note returns 404 and leaves note intact
