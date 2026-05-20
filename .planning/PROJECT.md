# GSD Notes App

## What This Is

A secure, private note-taking web application built on Rails 8.1. Authenticated users can create, view, edit, and delete their own encrypted notes — each with a markdown body and an optional file attachment. User accounts are managed exclusively by the webmaster via Rails console; self-registration is disabled.

## Core Value

Each user's notes are encrypted at rest and invisible to every other user — the app is useless if encryption or access isolation is broken.

## Requirements

### Validated

- ✓ Webmaster creates users via Rails console; no self-registration UI — v1.0
- ✓ User can sign in with email and password — v1.0
- ✓ User can sign out — v1.0
- ✓ User sees only their own notes — v1.0
- ✓ Notes are encrypted at rest using Active Record Encryption — v1.0
- ✓ User can create a note with a markdown body and an optional file attachment — v1.0
- ✓ User can edit a note (body and/or attachment) — v1.0
- ✓ User can delete a note — v1.0
- ✓ A note must have at least a body or a file attachment — model validation rejects notes with neither — v1.0
- ✓ Note title is derived from the first line of the body; falls back to attachment filename when body is absent — v1.0
- ✓ Notes are listed in a table showing: derived title, created date, updated date, attachment indicator — v1.0
- ✓ User can view a note with the markdown body rendered as HTML — v1.0
- ✓ User can download a note's file attachment — v1.0

### Active

- [ ] User can search or filter notes by title or body text (LIST-04)
- [ ] Notes table columns are sortable (LIST-05)
- [ ] Webmaster admin UI for user management beyond console (ADMIN-01)
- [ ] E2E system tests for row-click navigation, validation error UX, delete confirm (deferred from v1.0)
- [ ] Security header integration tests (deferred from v1.0)

### Out of Scope

- Self-registration / sign-up UI — webmaster-only user creation by design
- Sharing notes between users — strictly private per-user
- Multiple file attachments per note — one attachment only
- OAuth / SSO login — email/password sufficient for controlled deployment
- Mobile app — web-first

## Context

- Rails 8.1.3 app, Ruby 4.0.1
- Stack: Devise auth, Active Record Encryption, Active Storage (local disk), Redcarpet markdown, Propshaft, Importmap, Turbo, Stimulus
- Deployment: Kamal + Docker → single Linux VPS with SQLite, Solid Queue/Cache/Cable
- No external databases or message brokers required
- ~500 LOC Ruby/ERB app code (not counting gems, generated files)
- v1.0 shipped 2026-05-20 — two human developers + AI pair

## Constraints

- **Security**: Active Record Encryption required for note body and attachment metadata — non-negotiable
- **Access**: No user registration pathway — users created via `rails console` only
- **Tech Stack**: Rails 8.1 — no framework changes

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Title derived from body first line | Keeps notes self-describing without extra fields | ✓ Good |
| Attachment name as fallback title | Useful when note body is absent | ✓ Good |
| Active Record Encryption for body | Built-in Rails feature, no third-party key management needed for v1 | ✓ Good |
| No self-registration | Security-by-design for controlled deployment | ✓ Good |
| AuthenticatedController invariant | Auth enforcement in a single base class (not ApplicationController) | ✓ Good |
| body_or_file_present writes to :base | Correct Rails pattern for OR-constraint validation | ✓ Good — field--error CSS must check both [:body] and [:base] |
| CSP skipped in test env | Headless Chrome blocks importmap inline scripts under strict script-src 'self' | ✓ Good — intentional, documented |
| Error pages as standalone public/ HTML | ActionDispatch::Static serves them before Rails middleware — inline <style> is safe | ✓ Good |
| Kamal + SQLite for deployment | No external DB/broker needed for single-user-base VPS app | ✓ Good — simplifies ops |

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
*Last updated: 2026-05-20 after v1.0 milestone*
