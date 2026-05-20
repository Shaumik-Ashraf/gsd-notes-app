# Roadmap: GSD Notes App

**Phases:** 3 | **Requirements:** 19 | **Coverage:** 100% ✓
**Structure:** Vertical MVP — each phase delivers a working, usable increment

---

### Phase 1: Authentication & User Foundation ✓ Complete (2026-05-18)

**Goal:** A user can sign in, maintain a session, and sign out. Unauthenticated access is blocked. Webmaster can create users via console.
**Mode:** mvp
**Requirements:** AUTH-01, AUTH-02, AUTH-03, AUTH-04, SEC-02
**Plans:** 2/2 plans executed

**Success Criteria:**

1. ✓ A user with credentials created in the Rails console can sign in and land on the app
2. ✓ Refreshing the browser keeps the user signed in
3. ✓ Signing out returns the user to the sign-in page and blocks access to app routes
4. ✓ Navigating to any app route without being signed in redirects to sign-in
5. ✓ No sign-up/register link or route exists anywhere in the app

Plans:

- [x] 01-01-PLAN.md — Install Devise + User model + AuthenticatedController + routes (no self-registration); stub RootController
- [x] 01-02-PLAN.md — Customize Devise sign-in view per UI-SPEC, wire post-sign-in/sign-out redirects, write system test proving SC #1-5

---

### Phase 2: Notes CRUD with Encryption

**Goal:** An authenticated user can create, view, edit, and delete their own encrypted notes — each with a markdown body and/or a file attachment. Notes are listed in a table. All note data is encrypted at rest.
**Mode:** mvp
**Requirements:** NOTE-01, NOTE-02, NOTE-03, NOTE-04, NOTE-05, NOTE-06, NOTE-07, NOTE-08, NOTE-09, NOTE-10, LIST-01, LIST-02, LIST-03, SEC-01
**Plans:** 4 plans

**Success Criteria:**

1. A user can create a note with a body; it appears in the table with the first line as the title
2. A user can create a note with only a file attachment; the filename becomes the title
3. Submitting a note form with neither body nor attachment is rejected with a validation error
4. Note body is stored encrypted in the database (raw SQL query shows ciphertext, not plaintext)
5. A user can view a note and the markdown body is rendered as formatted HTML
6. A user can download the attached file from the note view page
7. A user can edit a note's body and/or replace the attachment
8. A user can delete a note; it no longer appears in the table
9. A user cannot see or access another user's notes (direct URL access returns 404 or redirect)
10. The notes table shows title, created date, updated date, and a clear attachment indicator

Plans:
**Wave 1**

- [ ] 02-01-PLAN.md — Encryption keys (blocking human checkpoint) + Redcarpet + Active Storage install + Note model with `encrypts :body` + User association + model tests (SEC-01, NOTE-06, NOTE-07, NOTE-10)

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 02-02-PLAN.md — Create + List vertical slice: routes, NotesController index/new/create, render_markdown helper, index/new/form views, layout nav bar, base CSS, system tests (NOTE-01, NOTE-02, NOTE-03, NOTE-06, NOTE-07, NOTE-10, LIST-01, LIST-02, LIST-03, SEC-01)

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 02-03-PLAN.md — Show + Download vertical slice: show action, sanitized markdown render, attachment download link, cross-user 404 + XSS sanitization system tests (NOTE-08, NOTE-09, LIST-03)

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] 02-04-PLAN.md — Edit + Update + Delete vertical slice: edit/update/destroy actions, edit view, file_purge wiring, synchronous attachment purge, full CRUD system tests (NOTE-04, NOTE-05)

---

### Phase 3: Polish & Hardening

**Goal:** The app is production-ready: secure defaults, proper error handling, clean UI, and edge cases handled.
**Mode:** mvp
**Requirements:** (cross-cutting — no new REQ-IDs; addresses quality across Phase 1 & 2 deliverables)
**Plans:** 3 plans

**Success Criteria:**

1. All forms show clear, user-friendly validation error messages
2. The app handles notes with very long first lines gracefully (title truncated in table)
3. File attachment download works correctly for binary files and large files
4. Signing in with wrong credentials shows an appropriate error message
5. The UI is clean and navigable without a README

Plans:
**Wave 1** *(parallel — no file overlap)*

- [ ] 03-01-PLAN.md — UI polish vertical slice: black-and-white CSS tokens, row-click + Actions column on notes table, top-right action bar on show page, per-field validation error UX, system tests (D-UI-01..06, D-ERR-01..02)
- [ ] 03-02-PLAN.md — Security hardening vertical slice: strict same-origin CSP, baseline HTTP security headers initializer, restyled public error pages, integration test (D-SEC-01, D-SEC-02, D-SEC-03)

**Wave 2** *(blocked on 03-02 — both touch production.rb)*

- [ ] 03-03-PLAN.md — Deployment documentation vertical slice: annotate production.rb with HSTS + mailer comments, write DEPLOYMENT.md walkthrough + deploy.yml audit, human-verify checkpoint (D-MAIL-01..02, D-DEPLOY-01..02)

---

## Requirement → Phase Traceability

| Requirement | Phase |
|-------------|-------|
| AUTH-01 | Phase 1 |
| AUTH-02 | Phase 1 |
| AUTH-03 | Phase 1 |
| AUTH-04 | Phase 1 |
| SEC-02 | Phase 1 |
| NOTE-01 | Phase 2 |
| NOTE-02 | Phase 2 |
| NOTE-03 | Phase 2 |
| NOTE-04 | Phase 2 |
| NOTE-05 | Phase 2 |
| NOTE-06 | Phase 2 |
| NOTE-07 | Phase 2 |
| NOTE-08 | Phase 2 |
| NOTE-09 | Phase 2 |
| NOTE-10 | Phase 2 |
| LIST-01 | Phase 2 |
| LIST-02 | Phase 2 |
| LIST-03 | Phase 2 |
| SEC-01 | Phase 2 |

**Coverage:**

- v1 requirements: 19 total
- Mapped to phases: 19
- Unmapped: 0 ✓

---
*Created: 2026-05-18*
