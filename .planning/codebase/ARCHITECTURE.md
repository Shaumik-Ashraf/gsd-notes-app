---
last_mapped: 2026-05-18
---

# Architecture

## Pattern

**Standard Rails MVC** — Model-View-Controller with full-stack server-rendered HTML via Hotwire for SPA-feel without a client-side framework.

## Application State

This is a **freshly generated Rails 8.1 skeleton** with no domain logic yet:
- No custom models (only `ApplicationRecord` base class)
- No custom controllers (only `ApplicationController` base class)
- No routes (only health check `/up` endpoint)
- No views (only layout templates and PWA stubs)

## Layers

```
Request
  └── Puma (web server) / Thruster (HTTP cache layer, production only)
        └── Rails Router (config/routes.rb)
              └── Controller (app/controllers/)
                    ├── Model (app/models/) — Active Record / SQLite3
                    ├── View (app/views/) — ERB templates
                    └── Hotwire response (Turbo Streams / Turbo Frames)

Background
  └── Solid Queue (app/jobs/) — DB-backed, runs in Puma process

Real-time
  └── Solid Cable (Action Cable) — DB-backed WebSocket adapter

Assets
  └── Propshaft → served by Thruster (production) / Puma (development)
        ├── CSS: app/assets/stylesheets/
        └── JS: app/javascript/ via Importmap
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
User Browser
  [1] GET request → Turbo Drive intercepts, XHR fetch
  [2] Rails renders full HTML (or Turbo frame/stream partial)
  [3] Turbo replaces page body / target frame
  [4] Stimulus controllers attach behavior to DOM elements
```

No client-side state management. Server is source of truth.

## Module Namespace

`GsdNotesApp` — defined in `config/application.rb`:
```ruby
module GsdNotesApp
  class Application < Rails::Application
```

## Configuration

- `config.autoload_lib(ignore: %w[assets tasks])` — lib/ is autoloaded except assets/tasks subdirs
- `config.load_defaults 8.1` — uses Rails 8.1 default configuration
