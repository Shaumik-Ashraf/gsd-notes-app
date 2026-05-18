---
phase: 01-authentication-user-foundation
reviewed: 2026-05-18T00:00:00Z
depth: standard
files_reviewed: 17
files_reviewed_list:
  - app/assets/stylesheets/application.css
  - app/controllers/application_controller.rb
  - app/controllers/authenticated_controller.rb
  - app/controllers/root_controller.rb
  - app/models/user.rb
  - app/views/devise/sessions/new.html.erb
  - app/views/devise/shared/_links.html.erb
  - app/views/layouts/application.html.erb
  - app/views/root/index.html.erb
  - config/initializers/devise.rb
  - config/locales/devise.en.yml
  - config/routes.rb
  - db/migrate/20260518194239_devise_create_users.rb
  - db/schema.rb
  - test/application_system_test_case.rb
  - test/fixtures/users.yml
  - test/system/authentication_test.rb
findings:
  critical: 2
  warning: 4
  info: 2
  total: 8
status: issues_found
---

# Phase 01: Code Review Report

**Reviewed:** 2026-05-18
**Depth:** standard
**Files Reviewed:** 17
**Status:** issues_found

## Summary

This phase implements Devise-based authentication with no self-registration. The login UI, controller hierarchy, and route constraints are structurally sound. However, two critical security gaps exist: the password reset endpoint is live and unauthenticated (because `skip: [:registrations]` does not skip `:passwords`), and Devise will confirm or deny whether an email exists during password reset because paranoid mode is off. Together these give an unauthenticated actor both user enumeration and the ability to trigger password-reset emails. Given that CLAUDE.md identifies encrypted notes privacy as the core value of this app, both issues must be resolved before this phase can be considered done.

---

## Critical Issues

### CR-01: Password Reset Routes Are Live and Unauthenticated

**File:** `config/routes.rb:2` and `app/models/user.rb:2`

**Issue:** `devise_for :users, skip: [:registrations]` skips only the `:registrations` module. It does **not** skip `:passwords`. As confirmed by `rails routes`, the following unauthenticated endpoints are active:

```
GET  /users/password/new    devise/passwords#new
GET  /users/password/edit   devise/passwords#edit
POST /users/password        devise/passwords#create
PUT  /users/password        devise/passwords#update
```

Any unauthenticated visitor can POST to `/users/password` with an arbitrary email and, if the mailer is configured, trigger a password reset email. The CLAUDE.md constraint states: "No user registration pathway — users created via `rails console` only." The same intent covers unauthenticated password recovery. Because the User model includes `:recoverable`, the module is fully operational.

**Fix:** Either remove `:recoverable` from the User model entirely (consistent with console-managed accounts) or explicitly skip the passwords controller in routes:

```ruby
# Option A — remove recoverable entirely (recommended for console-managed users)
# app/models/user.rb
devise :database_authenticatable, :validatable

# Option B — keep recoverable but block the unauthenticated routes
# config/routes.rb
devise_for :users, skip: [:registrations, :passwords]
```

Option A is the cleaner match for the stated design intent. If password reset must be retained for future use, also drop the `reset_password_token` and `reset_password_sent_at` columns from the schema to avoid a misleading dead-code migration.

---

### CR-02: User Enumeration via Password Reset (Paranoid Mode Disabled)

**File:** `config/initializers/devise.rb:93`

**Issue:** `config.paranoid` is commented out (disabled). Devise's default behavior is to respond differently when a submitted email is found versus not found in the database. With the password reset form live (see CR-01), an unauthenticated attacker can enumerate valid user accounts by submitting email addresses and observing whether the response says "email not found" or "instructions sent." This leaks the existence of user accounts — a meaningful privacy violation for a private notes app.

**Fix:** Enable paranoid mode unconditionally:

```ruby
# config/initializers/devise.rb
config.paranoid = true
```

This makes password reset (and any confirmable/unlockable flows) return the same message regardless of whether the email exists. This fix should be applied even if CR-01 is resolved via Option B, as defense in depth.

---

## Warnings

### WR-01: `config.reconfirmable = true` Is Inconsistent with the Schema and Model

**File:** `config/initializers/devise.rb:163`

**Issue:** `config.reconfirmable = true` is active, but the `:confirmable` module is not included in `User` (only `:database_authenticatable`, `:recoverable`, `:validatable` are declared). The `unconfirmed_email` column required by reconfirmable is also absent from the schema (the migration line is commented out at line 25 of the migration). This setting has no effect today, but it creates a misleading configuration and a latent trap: if `:confirmable` is added to the User model in a future phase without also adding the `unconfirmed_email` column, the app will raise `ActiveRecord::StatementInvalid` at runtime whenever a user's email is changed.

**Fix:** Comment out `config.reconfirmable` to match the model's actual modules, or add an explicit note explaining it is pre-staged for a future phase:

```ruby
# Reconfirmable is intentionally disabled: :confirmable is not in the User model
# and the unconfirmed_email column is not present in the schema.
# config.reconfirmable = true
```

---

### WR-02: No Session Timeout Configured

**File:** `config/initializers/devise.rb:194` and `app/models/user.rb:2`

**Issue:** `:timeoutable` is not in the User model, and `config.timeout_in` is commented out. Authenticated sessions never expire. For a private notes application handling sensitive encrypted content, an indefinitely-lived session is a meaningful risk: a user who walks away from an unlocked browser, or whose device is stolen, leaves the session active until the cookie is manually cleared or the server is restarted.

**Fix:** Add `:timeoutable` to the User model and configure a reasonable timeout:

```ruby
# app/models/user.rb
devise :database_authenticatable, :recoverable, :timeoutable, :validatable

# config/initializers/devise.rb
config.timeout_in = 30.minutes
```

---

### WR-03: No Brute-Force Protection (Lockable Not Configured)

**File:** `app/models/user.rb:2`

**Issue:** `:lockable` is not included in the User model and the lockable columns are commented out of the migration. The login endpoint at `POST /users/sign_in` has no rate limiting or account lockout. An attacker can make unlimited password attempts against any known account without triggering any defense. Combined with CR-02 (user enumeration), this is exploitable.

**Fix:** Add `:lockable` to the User model and uncomment the corresponding migration columns, or implement rack-level rate limiting. The Devise approach:

```ruby
# app/models/user.rb
devise :database_authenticatable, :lockable, :recoverable, :timeoutable, :validatable

# Add a new migration:
# add_column :users, :failed_attempts, :integer, default: 0, null: false
# add_column :users, :unlock_token, :string
# add_column :users, :locked_at, :datetime
# add_index  :users, :unlock_token, unique: true
```

Then configure in `devise.rb`:
```ruby
config.lock_strategy = :failed_attempts
config.maximum_attempts = 10
config.unlock_strategy = :time
config.unlock_in = 1.hour
```

---

### WR-04: Weak Minimum Password Length

**File:** `config/initializers/devise.rb:184`

**Issue:** `config.password_length = 6..128` allows passwords as short as 6 characters. CLAUDE.md states "each user's notes are encrypted at rest" and identifies the app as a security-focused private notes store. A 6-character minimum is well below modern guidance (NIST SP 800-63B recommends at least 8, with 12+ strongly preferred for sensitive systems). Users created via `rails console` should be required to set stronger passwords.

**Fix:** Raise the minimum to at least 12:

```ruby
config.password_length = 12..128
```

---

## Info

### IN-01: Devise Mailer Sender Is Placeholder

**File:** `config/initializers/devise.rb:27`

**Issue:** `config.mailer_sender` is set to the Devise default placeholder `please-change-me-at-config-initializers-devise@example.com`. Password reset emails (if the `:recoverable` module remains active) would be sent from this address. Even if password recovery is disabled (per CR-01 fix), this should be updated before any production deployment.

**Fix:**
```ruby
config.mailer_sender = "noreply@yourdomain.example.com"
```

---

### IN-02: `config.navigational_formats` Is Commented Out (Turbo Compatibility Risk)

**File:** `config/initializers/devise.rb:269`

**Issue:** The Hotwire/Turbo redirect status codes are configured (`config.responder.error_status = :unprocessable_content` and `config.responder.redirect_status = :see_other`) but `config.navigational_formats` remains commented out at the Devise default. The default does not include `:turbo_stream`, which can cause Devise redirects after sign-in/sign-out to misbehave with Turbo Drive in some browser states (particularly on Turbo form submissions that receive a 3xx). The Devise wiki and Rails 7+ upgrade guides recommend explicitly declaring:

```ruby
config.navigational_formats = ["*/*", :html, :turbo_stream]
```

This is low-risk for the current login form (a standard HTML form), but should be addressed before any Turbo Stream interactions are added to authenticated pages.

---

_Reviewed: 2026-05-18_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
