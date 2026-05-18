# GSD Notes App

## What This Is

A secure, private note-taking web application built on Rails. Authenticated users can create, view, edit, and delete their own encrypted notes — each with a markdown body and an optional file attachment. User accounts are managed exclusively by the webmaster via Rails console; self-registration is disabled.

## Core Value

Each user's notes are encrypted at rest and invisible to every other user — the app is useless if encryption or access isolation is broken.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Webmaster creates users via Rails console; no self-registration UI
- [ ] User can sign in with email and password
- [ ] User can sign out
- [ ] User sees only their own notes
- [ ] Notes are encrypted at rest using Active Record Encryption
- [ ] User can create a note with a markdown body and an optional file attachment
- [ ] User can edit a note (body and/or attachment)
- [ ] User can delete a note
- [ ] A note must have at least a body or a file attachment — model validation rejects notes with neither
- [ ] Note title is derived from the first line of the body; falls back to attachment filename when body is absent
- [ ] Notes are listed in a table showing: derived title, created date, updated date, attachment indicator
- [ ] User can view a note with the markdown body rendered as HTML
- [ ] User can download a note's file attachment

### Out of Scope

- Self-registration / sign-up UI — webmaster-only user creation by design
- Sharing notes between users — strictly private per-user
- Search / filter on notes list — defer to v2
- Multiple file attachments per note — one attachment only

## Context

- Rails 8.1 app (already initialized in this directory)
- Stack confirmed: Ruby on Rails with Active Record Encryption (built-in since Rails 7)
- File attachments via Active Storage (already bundled with Rails)
- Markdown rendering likely via a gem (e.g., Redcarpet or Commonmarker)
- Deployment context: self-hosted, controlled user base managed by webmaster

## Constraints

- **Security**: Active Record Encryption required for note body and attachment metadata — non-negotiable
- **Access**: No user registration pathway — users created via `rails console` only
- **Tech Stack**: Rails 8.1 — no framework changes

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Title derived from body first line | Keeps notes self-describing without extra fields | — Pending |
| Attachment name as fallback title | Useful when note body is absent | — Pending |
| Active Record Encryption for body | Built-in Rails feature, no third-party key management needed for v1 | — Pending |
| No self-registration | Security-by-design for controlled deployment | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-18 after initialization*
