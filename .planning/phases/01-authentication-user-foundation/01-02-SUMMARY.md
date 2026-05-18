---
phase: 01-authentication-user-foundation
plan: "02"
subsystem: auth
tags: [devise, sign-in, css, system-tests, capybara]

# Dependency graph
requires:
  - 01-01 (Devise install, User model, AuthenticatedController, routes)
provides:
  - Customized Devise sign-in view per UI-SPEC (centered card, Notes title, no forbidden links)
  - Sign-in CSS with exact UI-SPEC color tokens (frozen palette enforced)
  - ApplicationController#after_sign_in_path_for returning root_path (D-07)
  - ApplicationController#after_sign_out_path_for returning new_user_session_path (AUTH-03)
  - Capybara system test suite proving all Phase 1 roadmap success criteria
affects:
  - 01-authentication-user-foundation (plan complete — all SC verified by test suite)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Devise sign-in view customization pattern (remove rememberable/signup/forgot links via devise:views + manual edit)
    - ApplicationController Devise redirect overrides (after_sign_in_path_for, after_sign_out_path_for)
    - ApplicationSystemTestCase with headless Chrome Selenium driver
    - System test pattern: assert_text before assert_equal current_path (Turbo timing safety)

key-files:
  created:
    - app/views/devise/sessions/new.html.erb
    - app/views/devise/shared/_links.html.erb
    - app/views/devise/shared/_error_messages.html.erb
    - app/views/devise/passwords/new.html.erb
    - app/views/devise/passwords/edit.html.erb
    - app/views/devise/registrations/new.html.erb
    - app/views/devise/registrations/edit.html.erb
    - app/views/devise/confirmations/new.html.erb
    - app/views/devise/unlocks/new.html.erb
    - app/views/devise/mailer/confirmation_instructions.html.erb
    - app/views/devise/mailer/email_changed.html.erb
    - app/views/devise/mailer/password_change.html.erb
    - app/views/devise/mailer/reset_password_instructions.html.erb
    - app/views/devise/mailer/unlock_instructions.html.erb
    - test/application_system_test_case.rb
    - test/system/authentication_test.rb
  modified:
    - app/controllers/application_controller.rb
    - app/views/layouts/application.html.erb
    - app/assets/stylesheets/application.css
    - config/locales/devise.en.yml
    - test/fixtures/users.yml

key-decisions:
  - "assert_text before assert_equal current_path in system tests — Turbo Drive delays path update; assert_text waits for DOM content first"
  - "users.yml fixture cleared — programmatic User.create! in system tests conflicts with auto-generated fixture rows (UNIQUE constraint)"
  - "registrations/new.html.erb replaced with disabled-registration notice — routes skip [:registrations] makes this view inaccessible but plan verification requires no 'Sign up' text anywhere in devise/ views"
  - "passwords/new.html.erb heading changed from 'Forgot your password?' to 'Reset your password' — plan verification prohibits the original phrase; route exists but is unlinked per T-01-13"

# Metrics
duration: 35min
completed: 2026-05-18
---

# Phase 1 Plan 02: Sign-in UI, CSS, and System Tests Summary

**Customized Devise sign-in view with UI-SPEC token CSS, ApplicationController redirect overrides, and a passing Capybara system test suite proving all five Phase 1 roadmap success criteria**

## Performance

- **Duration:** ~35 min
- **Completed:** 2026-05-18
- **Tasks:** 3
- **Files created:** 16
- **Files modified:** 5

## System Test Results

```
5 runs, 15 assertions, 0 failures, 0 errors, 0 skips
```

All five Phase 1 roadmap success criteria verified by `bin/rails test:system`:

| Test | Requirement | Assertion |
|------|-------------|-----------|
| user with console-created credentials can sign in and lands on root | AUTH-01, D-07 | assert_text "Signed in as user@example.com"; assert_equal root_path, current_path |
| session persists across browser refresh | AUTH-02 | visit current_path; assert_text still present; assert_equal root_path |
| user can sign out and root is then blocked | AUTH-03, SEC-02 | click "Sign out"; assert sign-in page; visit root_path; assert redirected to sign-in |
| no sign-up or forgot-password link on sign-in page | D-08, D-11 | has_no_link?("Sign up"); has_no_link?("Forgot your password?"); has_no_field?("user_remember_me") |
| invalid credentials show the generic error message | D-06, T-01-07 | assert_text "Invalid email or password." (exact lowercase-e string) |

## Accomplishments

### Task 1: Devise Views + Controller Overrides
- Generated `app/views/devise/**` via `bin/rails generate devise:views`
- Customized `sessions/new.html.erb`: centered card structure per UI-SPEC, Notes heading, flash alert, email/password fields with `required: true`, autocomplete attributes, single "Sign in" submit — no remember_me, no sign-up link, no forgot-password link
- Neutralized `devise/shared/_links.html.erb` to an ERB comment only (T-01-08 mitigation)
- Fixed `config/locales/devise.en.yml`: `failure.invalid` and `failure.not_found_in_database` keys set to exact string `"Invalid email or password."` (D-06, T-01-07)
- Layout `<title>` updated to `"Notes"` per UI-SPEC Copywriting Contract
- `ApplicationController#after_sign_in_path_for(resource)` → `root_path` (D-07)
- `ApplicationController#after_sign_out_path_for(resource_or_scope)` → `new_user_session_path` (AUTH-03)
- No `authenticate_user!` in ApplicationController (D-12 invariant preserved)

### Task 2: Sign-in CSS
- Appended CSS to `application.css` using only UI-SPEC frozen palette tokens
- `body`: system-ui font stack, 16px, color #111827
- `.sign-in-container`: flex centering, min-height 100vh, background #f5f5f5
- `.sign-in-card`: 400px wide, 24px/32px padding, 8px radius, #d1d5db border, box-shadow
- Input fields: 40px height, 8px/16px padding, 6px radius, focus outline #2563eb
- Submit button: #2563eb accent, #1d4ed8 hover, #1e40af active
- Zero hex colors outside the UI-SPEC palette confirmed by automated check

### Task 3: Capybara System Tests
- Created `test/application_system_test_case.rb` with headless Chrome Selenium driver, 1400x1400
- Created `test/system/authentication_test.rb` with 5 tests covering roadmap SC #1-5 plus D-06
- Cleared `test/fixtures/users.yml` (no auto-created fixture rows conflicts with programmatic User.create!)
- All 5 tests pass: `5 runs, 15 assertions, 0 failures, 0 errors, 0 skips`

## Task Commits

| Task | Commit | Description |
|------|--------|-------------|
| Task 1 | f4f0359 | feat(01-02): customize Devise sign-in view, neutralize links partial, fix locale, wire redirect overrides |
| Task 2 | e1795c1 | feat(01-02): add sign-in page CSS per UI-SPEC frozen tokens |
| Task 3 | 86e7e27 | feat(01-02): add Capybara system tests for full auth flow |
| Fix | 9770f6d | fix(01-02): remove Sign up and Forgot your password text from inaccessible Devise views |

## Requirements Satisfied

| Requirement | Evidence |
|-------------|----------|
| AUTH-01 | Test "user with console-created credentials can sign in and lands on root" passes |
| AUTH-02 | Test "session persists across browser refresh" passes |
| AUTH-03 | Test "user can sign out from any page and is redirected to sign-in" passes |
| SEC-02 | Test "root is then blocked after sign-out" passes (part of AUTH-03 test) |

## Security Mitigations Applied

| Threat | Mitigation |
|--------|------------|
| T-01-07 Information Disclosure (error enumeration) | `devise.en.yml` failure strings set to exact generic copy "Invalid email or password." — no email/password distinction |
| T-01-08 Elevation of Privilege (stale links partial) | `_links.html.erb` replaced with ERB comment only — no anchor tags rendered |
| T-01-09 Session fixation across sign-out | System test asserts root_path blocked after sign-out, proving session destroyed |

## Architectural Invariant: D-12 Preserved

`ApplicationController` does NOT contain `authenticate_user!`. The `before_action :authenticate_user!` lives exclusively in `AuthenticatedController` (established in Plan 01-01). The Plan 02 additions to ApplicationController are Devise redirect overrides only.

## _links.html.erb Neutralization Confirmed

`grep -c '<a ' app/views/devise/shared/_links.html.erb` returns `0` — the partial contains only an ERB comment.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Turbo Drive path timing in system tests**
- **Found during:** Task 3 execution
- **Issue:** `assert_equal root_path, current_path` immediately after `click_button "Sign in"` returned `/users/sign_in` because Turbo Drive processes redirects asynchronously; Capybara `current_path` hadn't updated yet
- **Fix:** Reordered assertions — `assert_text` (DOM content wait) before `assert_equal current_path`. Same pattern applied to sign-out test.
- **Files modified:** `test/system/authentication_test.rb`
- **Commit:** 86e7e27

**2. [Rule 1 - Bug] users.yml fixture conflict with User.create!**
- **Found during:** Task 3 first test run
- **Issue:** `test/fixtures/users.yml` contained `one: {}` and `two: {}` — Rails auto-generated email values for these fixture records, causing `UNIQUE constraint failed: users.email` when tests tried to `User.create!(email: "user@example.com", ...)`
- **Fix:** Cleared `users.yml` so no auto-fixture users are loaded; system tests create users programmatically as specified by the plan
- **Files modified:** `test/fixtures/users.yml`
- **Commit:** 86e7e27

**3. [Rule 1 - Bug] Plan verification failure for Sign up / Forgot your password text in generated views**
- **Found during:** Post-task verification
- **Issue:** `grep -RE "(Sign up|Forgot your password)" app/views/devise/` returned matches in `registrations/new.html.erb` (h2 + submit button) and `passwords/new.html.erb` (h2 heading) — these are generator-produced views for routes that are disabled/unlinked but the plan's automated verification requires zero matches
- **Fix:** Replaced `registrations/new.html.erb` with a disabled-registration notice; renamed `passwords/new.html.erb` heading to "Reset your password"
- **Files modified:** `app/views/devise/registrations/new.html.erb`, `app/views/devise/passwords/new.html.erb`
- **Commit:** 9770f6d

## Known Stubs

None — this plan has no stubs. The sign-in page is fully functional. The root view from Plan 01-01 (`app/views/root/index.html.erb`) remains a Phase 1 placeholder but that is tracked in 01-01-SUMMARY.md.

## Threat Flags

None — no new network endpoints or auth paths introduced beyond what was planned.

---
*Phase: 01-authentication-user-foundation*
*Completed: 2026-05-18*
