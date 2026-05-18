---
plan: 02-01
phase: 02-notes-crud-with-encryption
status: complete
started: "2026-05-18"
completed: "2026-05-18"
key-files:
  created:
    - app/models/note.rb
    - test/models/note_test.rb
    - db/migrate/20260518220923_create_notes.rb
    - db/migrate/20260518220842_create_active_storage_tables.active_storage.rb
  modified:
    - Gemfile
    - Gemfile.lock
    - app/models/user.rb
    - test/fixtures/notes.yml
    - CLAUDE.md
    - db/schema.rb
requirements-covered:
  - SEC-01
  - NOTE-06
  - NOTE-07
  - NOTE-10
---

## What Was Built

Established the encrypted Note data foundation for Phase 2.

- **Active Record Encryption keys** generated and installed in `config/credentials.yml.enc` under `active_record_encryption` — verified readable at runtime; smoke check confirms SQL ciphertext ≠ plaintext
- **Redcarpet gem** added to Gemfile (`gem "redcarpet"`) for markdown rendering in later plans
- **Active Storage** installed via `rails active_storage:install`; tables (`active_storage_blobs`, `active_storage_attachments`, `active_storage_variant_records`) created and migrated
- **`notes` migration** generated with `user:references` (NOT NULL, FK) and `text :body` (nullable); `frozen_string_literal: true` header added per PATTERNS.md
- **`Note` model** defined with: `belongs_to :user`, `has_one_attached :file, dependent: :purge` (sync purge per D-07), `encrypts :body` (SEC-01), `body_or_file_present` custom validator (NOTE-10), `derived_title` instance method (NOTE-06, NOTE-07)
- **`User` model** updated with `has_many :notes, dependent: :destroy`
- **`test/models/note_test.rb`** — 9 tests covering: validation, encryption at rest (raw SQL assertion), `derived_title` (body first line, skips blanks, fallback to filename, fallback to "Untitled"), user destroy cascades to notes
- **`test/fixtures/notes.yml`** emptied to comment-only (encryption + fixture loading incompatibility)
- **`CLAUDE.md`** updated with `## Setup: Encryption Keys` section documenting the one-time setup requirement

## Test Results

```
9 runs, 12 assertions, 0 failures, 0 errors, 0 skips
```

Encryption smoke check: `bin/rails runner '... puts "OK"'` → `OK`

## Self-Check: PASSED

All must_haves satisfied:
- ✓ `rails db:encryption:init` keys pasted into credentials; `primary_key.present?` → `true`
- ✓ `Note.new(user:)` rejected without body or attachment — error on `:base`
- ✓ `derived_title` returns first non-blank body line / attachment filename / "Untitled"
- ✓ Raw SQL `SELECT body` returns ciphertext, not "plaintext-marker-xyz"
- ✓ `User has_many :notes, dependent: :destroy`
