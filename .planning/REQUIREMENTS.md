# Requirements: GSD Notes App

**Defined:** 2026-05-18
**Core Value:** Each user's notes are encrypted at rest and invisible to every other user

## v1 Requirements

### Authentication

- [ ] **AUTH-01**: User can sign in with email and password
- [ ] **AUTH-02**: User session persists across browser refresh
- [ ] **AUTH-03**: User can sign out from any page
- [x] **AUTH-04**: Webmaster can create a user via Rails console (no self-registration UI)

### Notes Management

- [ ] **NOTE-01**: User can create a note with a markdown body
- [ ] **NOTE-02**: User can attach a single file to a note (any file type)
- [ ] **NOTE-03**: User can create a note with only a file attachment (no body required)
- [ ] **NOTE-10**: A note must have at least a body or a file attachment — model validation rejects notes with neither
- [ ] **NOTE-04**: User can edit a note's body and/or replace the file attachment
- [ ] **NOTE-05**: User can delete a note permanently
- [ ] **NOTE-06**: Note title is derived from the first line of the body when body is present
- [ ] **NOTE-07**: Note title falls back to the attachment filename when body is absent
- [ ] **NOTE-08**: User can view a note with the markdown body rendered as HTML
- [ ] **NOTE-09**: User can download a note's file attachment

### Notes List

- [ ] **LIST-01**: User sees a table of their own notes on the main page
- [ ] **LIST-02**: Table shows: derived title, created date, updated date, attachment indicator
- [ ] **LIST-03**: User sees only their own notes (no cross-user visibility)

### Encryption & Security

- [ ] **SEC-01**: Note body is encrypted at rest using Active Record Encryption
- [x] **SEC-02**: Unauthenticated requests are redirected to the sign-in page

## v2 Requirements

### Notes List Enhancements

- **LIST-04**: User can search or filter notes by title or body text
- **LIST-05**: User can sort table columns

### Notifications / Admin

- **ADMIN-01**: Webmaster admin UI for user management (beyond console)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Self-registration | Deliberate security decision — webmaster-only user creation |
| Shared / collaborative notes | Strictly private per-user by design |
| Multiple file attachments per note | One attachment only for v1 |
| Search / filter on notes list | Deferred to v2 |
| OAuth / SSO login | Email/password sufficient for controlled deployment |
| Mobile app | Web-first |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 1 | Pending |
| AUTH-02 | Phase 1 | Pending |
| AUTH-03 | Phase 1 | Pending |
| AUTH-04 | Phase 1 | Complete |
| SEC-02 | Phase 1 | Complete |
| NOTE-01 | Phase 2 | Pending |
| NOTE-02 | Phase 2 | Pending |
| NOTE-03 | Phase 2 | Pending |
| NOTE-04 | Phase 2 | Pending |
| NOTE-05 | Phase 2 | Pending |
| NOTE-06 | Phase 2 | Pending |
| NOTE-07 | Phase 2 | Pending |
| NOTE-08 | Phase 2 | Pending |
| NOTE-09 | Phase 2 | Pending |
| NOTE-10 | Phase 2 | Pending |
| LIST-01 | Phase 2 | Pending |
| LIST-02 | Phase 2 | Pending |
| LIST-03 | Phase 2 | Pending |
| SEC-01 | Phase 2 | Pending |

**Coverage:**
- v1 requirements: 19 total
- Mapped to phases: 19
- Unmapped: 0 ✓

---
*Requirements defined: 2026-05-18*
*Last updated: 2026-05-18 after initial definition*
