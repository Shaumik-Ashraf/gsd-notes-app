<!-- GSD:project-start source:PROJECT.md -->
## Project

**GSD Notes App**

A secure, private note-taking web application built on Rails. Authenticated users can create, view, edit, and delete their own encrypted notes — each with a markdown body and an optional file attachment. User accounts are managed exclusively by the webmaster via Rails console; self-registration is disabled.

**Core Value:** Each user's notes are encrypted at rest and invisible to every other user — the app is useless if encryption or access isolation is broken.

### Constraints

- **Security**: Active Record Encryption required for note body and attachment metadata — non-negotiable
- **Access**: No user registration pathway — users created via `rails console` only
- **Tech Stack**: Rails 8.1 — no framework changes

### Contribution Rules

- AI and Agents must not write or commit to git, instead instruct the user to check and write to git.
- Unit tests and/or integration tests must be added where applicable.
- Tests must not be re-written, and every feature must be tested exactly once unless explicitly specified otherwise.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Language & Runtime
| Component | Version | Notes |
|-----------|---------|-------|
| Ruby | 4.0.1 | See `.ruby-version` |
| Rails | 8.1.3 | `gem "rails", "~> 8.1.3"` in `Gemfile` |
## Web Framework
- **Action Controller** — `ApplicationController < ActionController::Base` with `allow_browser versions: :modern` and importmap etag invalidation
- **Active Record** — SQLite3 adapter
- **Active Storage** — local disk (development), disk (test), configurable for S3/GCS via `config/storage.yml`
- **Action Mailer** — configured for localhost in development
- **Active Job** — backed by Solid Queue
- **Action Cable** — backed by Solid Cable
## Database
- **Adapter**: SQLite3 (`gem "sqlite3", ">= 2.1"`)
- **Development DB**: `storage/development.sqlite3`
- **Test DB**: `storage/test.sqlite3`
- **Production**: Multiple SQLite DBs — primary + dedicated DBs for cache, queue, cable
## Asset Pipeline
- **Propshaft** (`gem "propshaft"`) — modern asset pipeline, no preprocessing by default
- **CSS**: Single manifest file `app/assets/stylesheets/application.css` — plain CSS, no preprocessor
- **JavaScript**: Importmap (`gem "importmap-rails"`) — pins via `config/importmap.rb`, no bundler/npm
## Frontend Framework
- **Turbo** (`@hotwired/turbo-rails`) — SPA-like navigation and form submissions
- **Stimulus** (`@hotwired/stimulus`) — modest JS framework for behavior attachment
- Entry: `app/javascript/application.js`, controllers in `app/javascript/controllers/`
- Currently only a scaffold `hello_controller.js` setting textContent to "Hello World!"
## Web Server
- **Puma** (`gem "puma", ">= 5.0"`) — multi-threaded Rack server
- **Thruster** (`gem "thruster"`) — HTTP asset caching/compression and X-Sendfile for production, wraps Puma
## Background Jobs
- **Solid Queue** (`gem "solid_queue"`) — DB-backed job queue using SQLite; runs inside Puma via `SOLID_QUEUE_IN_PUMA: true` in deployment
## Caching
- **Solid Cache** (`gem "solid_cache"`) — DB-backed Rails cache store
## Real-time
- **Solid Cable** (`gem "solid_cable"`) — DB-backed Action Cable adapter
## Deployment
- **Kamal** (`gem "kamal"`) — Docker-based deployment tool; config at `config/deploy.yml`
- **Docker** — multi-stage Dockerfile, targets `amd64`, uses `ruby:4.0.1-slim` base
- **jemalloc** — enabled in production (`LD_PRELOAD`) for reduced memory usage
- **Bootsnap** (`gem "bootsnap"`) — boot time cache
## Security Tools (dev/test)
- **Brakeman** — static analysis for Rails security vulnerabilities (`bin/brakeman`)
- **bundler-audit** — known CVE scanning for gems (`bin/bundler-audit`)
- **RuboCop** with `rubocop-rails-omakase` — Rails Omakase style enforcement
## Testing
- Rails default minitest (see TESTING.md for details)
- **Capybara** + **Selenium WebDriver** — system/browser tests
## JSON
- **Jbuilder** (`gem "jbuilder"`) — JSON view builder (not yet used)
## PWA Support
- `app/views/pwa/manifest.json.erb` and `service-worker.js` present but commented out in routes
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Style Enforcer
## Ruby Style (Omakase defaults)
- Double quotes for strings
- Two-space indentation
- Trailing commas in multiline arrays/hashes
- `frozen_string_literal: true` not enforced by default
- No `and`/`or` keywords (use `&&`/`||`)
- Method parentheses omitted when unambiguous
## Rails Patterns
### Controllers
### Models
### Views / Templates
- ERB (`.html.erb`) for server-rendered HTML
- Jbuilder (`.json.jbuilder`) for JSON responses when needed
- No view components gem yet (plain partials expected)
### JavaScript
### Background Jobs
### Mailers
## Parameter Filtering
- `:passw`, `:email`, `:secret`, `:token`, `:_key`, `:crypt`, `:salt`, `:certificate`, `:otp`, `:ssn`, `:cvv`, `:cvc`
## Error Handling
- Public error pages in `public/` (400, 404, 406, 422, 500)
- `consider_all_requests_local = true` in development (full stack traces)
## Content Security Policy
## Assets
- CSS: standard cascade, no preprocessor. One `application.css` manifest imports all stylesheets.
- Images: in `app/assets/images/`
- Vendored JS: `vendor/javascript/` for importmap-pinned packages
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern
## Application State
- No custom models (only `ApplicationRecord` base class)
- No custom controllers (only `ApplicationController` base class)
- No routes (only health check `/up` endpoint)
- No views (only layout templates and PWA stubs)
## Layers
```
```
## Entry Points
| Entry Point | File | Purpose |
|-------------|------|---------|
| HTTP server | `bin/rails server` | Development |
| Production server | `bin/thrust ./bin/rails server` | Production via Docker |
| Background jobs | `bin/jobs` | Job processor (Solid Queue) |
| Docker entrypoint | `bin/docker-entrypoint` | Prepares DB before server start |
| Health check | `GET /up` | Load balancer / uptime monitor |
## Key Abstractions
- **`ApplicationRecord`** (`app/models/application_record.rb`) — base model, inherits from `ActiveRecord::Base`
- **`ApplicationController`** (`app/controllers/application_controller.rb`) — base controller with browser version restriction and importmap etag invalidation
- **`ApplicationJob`** (`app/jobs/application_job.rb`) — base job class
- **`ApplicationMailer`** (`app/mailers/application_mailer.rb`) — base mailer class
## Data Flow
```
```
## Module Namespace
```ruby
```
## Configuration
- `config.autoload_lib(ignore: %w[assets tasks])` — lib/ is autoloaded except assets/tasks subdirs
- `config.load_defaults 8.1` — uses Rails 8.1 default configuration
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
