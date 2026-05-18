---
last_mapped: 2026-05-18
---

# Technology Stack

## Language & Runtime

| Component | Version | Notes |
|-----------|---------|-------|
| Ruby | 4.0.1 | See `.ruby-version` |
| Rails | 8.1.3 | `gem "rails", "~> 8.1.3"` in `Gemfile` |

## Web Framework

**Ruby on Rails 8.1** — full-stack MVC framework with the full `rails/all` require. Uses defaults 8.1 config (`config.load_defaults 8.1`).

Key Rails components in use:
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
