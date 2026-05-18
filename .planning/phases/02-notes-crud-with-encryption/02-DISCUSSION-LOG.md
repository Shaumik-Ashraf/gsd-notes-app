# Phase 2: Notes CRUD with Encryption - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-18
**Phase:** 2-notes-crud-with-encryption
**Areas discussed:** Markdown renderer, Encryption key setup, Attachment edit behavior, Body editor UX

---

## Markdown Renderer

| Option | Description | Selected |
|--------|-------------|----------|
| Redcarpet | Most widely used Rails markdown gem. Fast C extension. Flexible options (fenced code, autolink, strikethrough). Requires explicit sanitization. | ✓ |
| Commonmarker | GitHub Flavored Markdown (GFM). Native C extension via libcmark. Good render quality. Less common in Rails apps. | |
| Kramdown | Pure Ruby (no native ext). Used by Jekyll. Slower for large docs but zero compilation issues. | |

**User's choice:** Redcarpet

**Sanitization sub-question:**

| Option | Description | Selected |
|--------|-------------|----------|
| Rails built-in sanitizer | Use ActionView's `sanitize()` helper with a safe allowlist. Zero extra gems. Already in Rails. | ✓ |
| Sanitize gem | More configurable allowlist gem. Useful if fine-grained control is needed. Adds a dependency. | |
| You decide | Leave the sanitization approach to the planner/executor. | |

**User's choice:** Rails built-in sanitizer

---

## Encryption Key Setup

| Option | Description | Selected |
|--------|-------------|----------|
| Rails credentials | Keys stored in config/credentials.yml.enc, encrypted with RAILS_MASTER_KEY. Standard Rails approach. | ✓ |
| ENV vars | Keys set as environment variables. Simpler for 12-factor deployments but must be kept out of git. | |
| You decide | Leave to planner/executor. | |

**User's choice:** Rails credentials

**Key generation sub-question:**

| Option | Description | Selected |
|--------|-------------|----------|
| Generate once, document in CLAUDE.md/README | Run `rails db:encryption:init`, paste output into credentials. Document the setup step. | ✓ |
| Deterministic dev keys (hardcoded for dev only) | Use known values in development.rb for easy onboarding. Production still uses real secrets. | |

**User's choice:** Generate once, document in CLAUDE.md/README

---

## Attachment Edit Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — allow remove-only | Show a 'Remove attachment' checkbox in edit form. Handles the valid state: note has body only. | ✓ |
| No — replace-only | Users can upload a new file (replacing old) but can't remove without replacing. | |

**User's choice:** Allow remove-only (and replacement) — free-text clarification: "allow remove and replace"

**Purge strategy sub-question:**

| Option | Description | Selected |
|--------|-------------|----------|
| :purge (synchronous) | Attachment deleted immediately in-request. Simple, test-friendly. `dependent: :purge`. | ✓ |
| :purge_later (async) | Deletion queued as background job via Solid Queue. Better for large files in production. | |

**User's choice:** :purge (synchronous)

---

## Body Editor UX

| Option | Description | Selected |
|--------|-------------|----------|
| Plain \<textarea\> | Standard HTML textarea. Zero JS dependencies. Fast and simple. User writes raw markdown. | ✓ |
| Lightweight markdown editor (EasyMDE/SimpleMDE) | JS-based editor with toolbar, preview toggle. Pin via importmap CDN. ~100KB of JS. | |
| Split-pane preview | Textarea on left, live-rendered preview on right via Stimulus controller. Medium complexity. | |

**User's choice:** Plain \<textarea\>

---

## Claude's Discretion

- Exact Redcarpet render options (`:fenced_code_blocks`, `:autolink`, etc.) — use sensible defaults
- CSS styling for notes table and forms — keep clean but unstyled (Phase 3 handles polish)
- Exact column types in migration (string vs text for body, etc.)
- Helper method name/location for markdown rendering utility

## Deferred Ideas

None emerged during discussion.
