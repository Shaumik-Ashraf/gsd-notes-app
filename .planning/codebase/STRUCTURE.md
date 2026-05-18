---
last_mapped: 2026-05-18
---

# Directory Structure

## Top-Level Layout

```
gsd-notes-app/
├── app/                    # Core application code
│   ├── assets/             # Static assets (images, CSS)
│   ├── controllers/        # Request handling
│   ├── helpers/            # View helpers
│   ├── javascript/         # Stimulus controllers, JS entrypoint
│   ├── jobs/               # Background jobs
│   ├── mailers/            # Email classes
│   ├── models/             # Active Record models
│   └── views/              # ERB templates
├── bin/                    # Executable scripts
├── config/                 # Application configuration
│   ├── environments/       # Per-env overrides (dev/test/prod)
│   ├── initializers/       # Boot-time configs
│   └── locales/            # i18n files
├── db/                     # Database schemas and seeds
├── lib/                    # Reusable library code
│   └── tasks/              # Rake tasks
├── public/                 # Static files served directly
├── test/                   # Test suite
│   ├── controllers/
│   ├── fixtures/
│   ├── helpers/
│   ├── integration/
│   ├── mailers/
│   └── models/
├── tmp/                    # Tmp files (cache, pids, storage)
├── vendor/javascript/      # Vendored JS (importmap pins)
├── .github/workflows/      # GitHub Actions CI
└── .kamal/                 # Kamal deployment hooks/secrets
```

## Key Files

| File | Purpose |
|------|---------|
| `Gemfile` | Ruby dependency declarations |
| `config/routes.rb` | URL routing — currently only `/up` health check |
| `config/database.yml` | Database connections per environment |
| `config/importmap.rb` | JavaScript import map pins |
| `config/application.rb` | Application class and default settings |
| `config/deploy.yml` | Kamal deployment configuration |
| `config/storage.yml` | Active Storage service configuration |
| `config/puma.rb` | Puma web server configuration |
| `config/queue.yml` | Solid Queue configuration |
| `config/cache.yml` | Solid Cache configuration |
| `config/cable.yml` | Solid Cable configuration |
| `config/recurring.yml` | Recurring job configuration |
| `Dockerfile` | Multi-stage production container |
| `bin/ci` | CI runner script |
| `bin/dev` | Local development startup |
| `bin/docker-entrypoint` | Container startup (DB prep) |
| `.rubocop.yml` | RuboCop inherits `rubocop-rails-omakase` |

## JavaScript Layout

```
app/javascript/
├── application.js              # Entrypoint: imports Turbo, Stimulus controllers
└── controllers/
    ├── application.js          # Stimulus Application instance
    ├── index.js                # Auto-imports all controllers
    └── hello_controller.js     # Example scaffold controller
```

## Views Layout

```
app/views/
├── layouts/
│   ├── application.html.erb    # Main HTML layout (PWA meta, importmap, stylesheet)
│   ├── mailer.html.erb         # HTML email layout
│   └── mailer.text.erb         # Plain text email layout
└── pwa/
    ├── manifest.json.erb       # PWA manifest (routes commented out)
    └── service-worker.js       # Service worker stub
```

## Naming Conventions

- Controllers: `PascalCase` class, `snake_case` file — e.g., `NotesController` in `notes_controller.rb`
- Models: singular `PascalCase` — e.g., `Note`
- Views: `app/views/notes/index.html.erb` mirrors controller/action
- Jobs: `PascalCase` suffix `Job` — e.g., `ProcessNoteJob`
- Helpers: `PascalCase` suffix `Helper`
- Fixtures: `/test/fixtures/<table_name>.yml`
