# Phase 1: Authentication & User Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-18
**Phase:** 1-authentication-user-foundation
**Areas discussed:** Auth library, Sign-in page UX, Session duration, Access control scope

---

## Auth Library

| Option | Description | Selected |
|--------|-------------|----------|
| has_secure_password (Recommended) | Built into Rails — no gem needed. BCrypt hashing, authenticate method. Best fit for no self-registration, no email verification in v1. | |
| Devise | Full-featured auth gem with generators, views, and magic. More to configure/disable for this constrained use case. | ✓ |
| You decide | Leave library choice to the planner. | |

**User's choice:** Devise

---

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal: :database_authenticatable + :validatable only | Sign in, sign out, BCrypt, email/password validations. No registration, recovery, or lockout. | |
| Standard: add :recoverable + :rememberable | Adds password reset via email and remember-me cookie. | ✓ |
| You decide | Let planner configure sensible modules. | |

**User's choice:** Standard (with :recoverable + :rememberable)

---

| Option | Description | Selected |
|--------|-------------|----------|
| Email + password only (Recommended) | No extra fields — Devise provides what's needed. | ✓ |
| Add a display name field | `name` or `display_name` column on User. | |

**User's choice:** Email + password only

---

| Option | Description | Selected |
|--------|-------------|----------|
| Enable :recoverable but skip mailer setup for now | Module in model, webmaster resets via console, mailer deferred. | ✓ |
| Wire it up fully in Phase 1 | Configure ActionMailer + Devise mailer in this phase. | |
| You decide | Leave to planner. | |

**User's choice:** Enable module but skip mailer setup
**Notes:** User added: "Add Mailer Setup as a TODO for production setup phase — MUST be clearly documented for both humans and AI."
**Additional decision from follow-up:** Remove :rememberable entirely from the Devise model (not just hidden in UI).

---

## Sign-in Page UX

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal functional form (Recommended) | Plain centered form — fastest path through Phase 1. | |
| Clean but presentable | Centered card/panel with simple title, basic styling — not polished but not embarrassing. | ✓ |

**User's choice:** Clean but presentable

---

| Option | Description | Selected |
|--------|-------------|----------|
| Generic: "Invalid email or password" (Recommended) | Doesn't leak whether email exists. Better security. | ✓ |
| Specific: separate messages for wrong email vs. wrong password | More user-friendly but reveals account existence. | |

**User's choice:** Generic error message

---

| Option | Description | Selected |
|--------|-------------|----------|
| Always the notes list (Recommended) | Simple, predictable destination. | ✓ |
| Requested page if available, else notes list | Redirect back to original URL using store_location_for. | |

**User's choice:** Always notes list

---

| Option | Description | Selected |
|--------|-------------|----------|
| Generate Devise views and customize (Recommended) | `rails generate devise:views` for editable ERB. Full control over markup. | ✓ |
| Leave Devise views as-is | Use default gem views. Minimal effort, no control over HTML. | |

**User's choice:** Generate Devise views and customize

---

## Session Duration

| Option | Description | Selected |
|--------|-------------|----------|
| Session ends on browser close (Recommended) | Standard Rails cookie session. Clean, secure default. | ✓ |
| Session persists across browser close | Persistent cookie with expiry using :rememberable. | |

**User's choice:** Session ends on browser close

---

| Option | Description | Selected |
|--------|-------------|----------|
| No idle timeout (Recommended) | Session lives until browser close. Simple, no server-side tracking. | ✓ |
| Yes — sign out after N minutes of inactivity | Requires :timeoutable or custom middleware. More implementation scope. | |

**User's choice:** No idle timeout

---

| Option | Description | Selected |
|--------|-------------|----------|
| No "Remember me" checkbox (Recommended) | :rememberable present but not exposed in UI. | |
| Show a "Remember me" checkbox | Opt-into persistent cookie. | |

**User's choice (via "Other" free-text):** No checkbox AND remove :rememberable from the Devise model entirely.

---

## Access Control Scope

| Option | Description | Selected |
|--------|-------------|----------|
| before_action :authenticate_user! in ApplicationController (Recommended) | All routes protected by default. | |
| Opt-in per controller | Only controllers that explicitly call authenticate_user! are protected. | |

**User's choice (via "Other" free-text):** Neither as-is — create `AuthenticatedController < ApplicationController` that applies `authenticate_user!`. All secured controllers MUST subclass `AuthenticatedController`.
**Notes:** This is an architectural invariant — not just a preference. The planner and executor must enforce it.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — /up stays public (Recommended) | Health check accessible without auth for monitoring tools. | ✓ |
| No — /up also requires auth | Simpler config but breaks automated monitoring. | |

**User's choice:** /up stays public

---

| Option | Description | Selected |
|--------|-------------|----------|
| Redirect to sign-in page (Recommended) | Standard Devise behavior via authenticate_user!. | ✓ |
| Return 401 for non-HTML, redirect for HTML | Correct for API+browser apps — not needed for browser-only app. | |

**User's choice:** Redirect to sign-in page

---

## Claude's Discretion

- Route organization and Devise route configuration details
- CSS styling details for the sign-in card (beyond "clean centered card")
- Exact Devise configuration options beyond the specified modules

## Deferred Ideas

- **Mailer setup for password recovery** — `:recoverable` installed but ActionMailer delivery NOT configured in Phase 1. Must be set up and documented before production deployment. Candidate for Phase 3 (Polish & Hardening) or a deployment/ops phase.
