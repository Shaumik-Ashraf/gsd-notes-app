---
status: partial
phase: 01-authentication-user-foundation
source: [01-VERIFICATION.md]
started: 2026-05-18T00:00:00Z
updated: 2026-05-18T00:00:00Z
---

## Current Test

[awaiting human testing]

## Tests

### 1. Live redirect for unauthenticated root access (SEC-02)
expected: Visiting `http://localhost:3000/` while not signed in returns HTTP 302 and redirects to `/users/sign_in`
result: [pending]

### 2. Session persistence across browser refresh (AUTH-02)
expected: After signing in, pressing F5 / refreshing the browser keeps the user on the root page (not redirected back to sign-in)
result: [pending]

### 3. Invalid-credentials error message rendering (D-06)
expected: Submitting incorrect password shows the exact string "Invalid email or password." displayed inside the sign-in card (not in the layout flash outside the card)
result: [pending]

### 4. Visual UI conformance (UI-SPEC)
expected: Sign-in page renders with: centered white card on grey background (#f5f5f5), "Notes" heading, email + password fields, blue "Sign in" button; no "Sign up" link, no "Forgot your password?" link, no "Remember me" checkbox
result: [pending]

## Summary

total: 4
passed: 0
issues: 0
pending: 4
skipped: 0
blocked: 0

## Gaps
