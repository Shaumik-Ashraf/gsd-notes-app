---
phase: 01-authentication-user-foundation
plan: "01"
subsystem: auth
tags: [devise, bcrypt, authentication, rails]

# Dependency graph
requires: []
provides:
  - Devise 5.0.4 gem installed with bcrypt
  - User model with :database_authenticatable, :recoverable, :validatable (no :rememberable)
  - Users table migrated (no remember_created_at column)
  - AuthenticatedController < ApplicationController with before_action :authenticate_user!
  - RootController < AuthenticatedController (Phase 1 placeholder)
  - Devise routes with skip: [:registrations] (no self-registration)
  - Root path wired to authenticated controller
  - /up health check preserved as public
affects:
  - 01-authentication-user-foundation (Plan 02 — sign-in UI builds on top of this)
  - All future feature controllers must subclass AuthenticatedController (D-13 invariant)

# Tech tracking
tech-stack:
  added: [devise 5.0.4, bcrypt]
  patterns:
    - AuthenticatedController < ApplicationController (auth enforcement point, D-12)
    - All feature controllers subclass AuthenticatedController not ApplicationController (D-13)
    - devise_for :users, skip: [:registrations] (no self-registration)

key-files:
  created:
    - app/models/user.rb
    - app/controllers/authenticated_controller.rb
    - app/controllers/root_controller.rb
    - app/views/root/index.html.erb
    - db/migrate/20260518194239_devise_create_users.rb
    - db/schema.rb
    - config/initializers/devise.rb
    - config/locales/devise.en.yml
  modified:
    - Gemfile
    - Gemfile.lock
    - config/routes.rb

key-decisions:
  - "Devise modules: :database_authenticatable, :recoverable, :validatable only — :rememberable removed from model AND migration (D-02, D-11)"
  - "AuthenticatedController is the auth enforcement point, not ApplicationController (D-12)"
  - "All authenticated controllers subclass AuthenticatedController — RootController demonstrates the pattern (D-13)"
  - "Self-registration disabled via devise_for :users, skip: [:registrations] (D-04)"
  - "ActionMailer not configured in Phase 1 — :recoverable installed but password reset emails deferred to Phase 3 (D-04)"

patterns-established:
  - "AuthenticatedController pattern: class AuthenticatedController < ApplicationController with single before_action :authenticate_user!"
  - "Feature controller pattern: class FeatureController < AuthenticatedController (never < ApplicationController)"
  - "Devise routes pattern: devise_for :users, skip: [:registrations]"

requirements-completed: [AUTH-04, SEC-02]

# Metrics
duration: 23min
completed: 2026-05-18
---

# Phase 1 Plan 01: Devise Installation & Auth Foundation Summary

**Devise 5.0.4 installed with User model (database_authenticatable/recoverable/validatable, no rememberable), users table migrated, AuthenticatedController enforcement point and stub RootController wired with no self-registration routes**

## Performance

- **Duration:** ~23 min
- **Started:** 2026-05-18T19:21:40Z
- **Completed:** 2026-05-18T19:44:41Z
- **Tasks:** 3
- **Files modified:** 11

## Accomplishments
- Devise 5.0.4 gem and bcrypt installed; Devise initializer and locale files generated
- User model with exactly `devise :database_authenticatable, :recoverable, :validatable` — :rememberable removed from both model and migration; users table migrated without `remember_created_at` column
- AuthenticatedController architectural invariant established: `before_action :authenticate_user!` lives in `AuthenticatedController < ApplicationController`, not in ApplicationController; RootController inherits from AuthenticatedController demonstrating the D-13 invariant; routes expose sign-in/sign-out with no sign-up routes; `/up` preserved as public

## Task Commits

Each task was committed atomically:

1. **Task 1: Install Devise gem, uncomment bcrypt, generate Devise install files** - `f74d5d3` (chore)
2. **Task 2: Generate User model with approved Devise modules, remove rememberable** - `fc03e8a` (feat)
3. **Task 3: Create AuthenticatedController + stub RootController, wire routes** - `f2f4fbd` (feat)

**Plan metadata:** (docs commit — see below)

## Files Created/Modified
- `Gemfile` - Added `gem "devise"` and uncommented `gem "bcrypt", "~> 3.1.7"`
- `Gemfile.lock` - Locked devise 5.0.4 and bcrypt
- `config/initializers/devise.rb` - Devise initializer (generator output; no mailer config per D-04)
- `config/locales/devise.en.yml` - Devise English locale strings
- `app/models/user.rb` - User model with three approved Devise modules only
- `db/migrate/20260518194239_devise_create_users.rb` - Migration with rememberable block removed
- `db/schema.rb` - Generated schema; users table confirmed without remember_created_at
- `app/controllers/authenticated_controller.rb` - Auth enforcement base controller (D-12)
- `app/controllers/root_controller.rb` - Phase 1 placeholder subclassing AuthenticatedController (D-13)
- `app/views/root/index.html.erb` - Stub landing view with current_user.email and sign-out button
- `config/routes.rb` - devise_for with skip: [:registrations], root "root#index", /up preserved

## Decisions Made
- Followed all frozen decisions from CONTEXT.md (D-01 through D-15)
- ActionMailer delivery left unconfigured per D-04 — :recoverable installed for Phase 3 mailer setup
- Generator auto-inserted `devise_for :users` in routes without `skip:` — corrected in Task 3 to `devise_for :users, skip: [:registrations]`

## Deviations from Plan

None — plan executed exactly as written. The generator inserting plain `devise_for :users` in routes.rb was expected behavior; Task 3 replaced it with the correct skip variant as specified.

## Issues Encountered
- `Devise::VERSION` constant does not exist in Devise 5.0.4 (the plan's acceptance criterion `bundle exec ruby -e 'require "devise"; puts Devise::VERSION'` would fail). Verified devise is correctly installed via `require "devise"` loading without error. All other acceptance criteria passed.

## Known Stubs
- `app/views/root/index.html.erb` — Phase 1 placeholder view with minimal content. Phase 2 replaces this with the notes list (root "notes#index" and NotesController).

## AUTH-04 Console Flow Verification

```bash
bin/rails runner 'User.create!(email: "smoke@example.com", password: "password123"); puts User.find_by(email: "smoke@example.com").persisted?'
# => true
```

Webmaster can create users via `bin/rails console` or `bin/rails runner`. Self-registration UI does not exist.

## Rememberable-Free State

- `grep ":rememberable" app/models/user.rb` — no match
- `grep "remember_created_at" db/migrate/20260518194239_devise_create_users.rb` — no match
- `grep "remember_created_at" db/schema.rb` — no match
- `bin/rails runner 'puts User.new.respond_to?(:remember_me)'` — prints `false`

## User Setup Required
None — no external service configuration required.

## Next Phase Readiness
- Plan 02 (Sign-in UI) can now build on this foundation: Devise routes are wired, AuthenticatedController enforces authentication, RootController is the post-sign-in destination
- Plan 02 must generate Devise views (`rails g devise:views`), customize the sign-in page, and wire flash messages in layout
- Architectural invariant (D-13) is enforced: any future controller serving authenticated routes must subclass AuthenticatedController

---
*Phase: 01-authentication-user-foundation*
*Completed: 2026-05-18*
