---
last_mapped: 2026-05-18
---

# Testing

## Framework

**Minitest** — Rails default. No RSpec or other testing frameworks added.

## Test Helper

`test/test_helper.rb` — base configuration:
```ruby
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)  # parallel test execution
    fixtures :all                                 # all fixtures loaded
  end
end
```

## Parallel Execution

Tests run in parallel using `parallelize(workers: :number_of_processors)`. Each worker gets its own database.

## Test Categories

| Type | Directory | Base Class |
|------|-----------|------------|
| Model tests | `test/models/` | `ActiveSupport::TestCase` |
| Controller tests | `test/controllers/` | `ActionDispatch::IntegrationTest` |
| Integration tests | `test/integration/` | `ActionDispatch::IntegrationTest` |
| Mailer tests | `test/mailers/` | `ActionMailer::TestCase` |
| Helper tests | `test/helpers/` | `ActionView::TestCase` |
| System tests | (would go in `test/system/`) | `ApplicationSystemTestCase` |

All directories currently contain only `.keep` files — no tests written yet.

## System Testing

**Capybara** + **Selenium WebDriver** gems are installed. System tests would require `libvips` (installed in CI). No system tests exist yet.

## Fixtures

Fixture files in `test/fixtures/` (subdirectory `files/` for file fixtures). Auto-loaded via `fixtures :all`. Currently only `.keep` placeholder.

## CI Test Execution

GitHub Actions (`.github/workflows/ci.yml`):
```yaml
- name: Install packages
  run: sudo apt-get install --no-install-recommends -y libvips
- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    bundler-cache: true
- name: Run tests
  run: bin/rails test test:system
```

## Security Scanning (runs alongside tests in CI)

- `bin/brakeman --no-pager` — Rails security static analysis
- `bin/bundler-audit` — gem CVE scanning (config: `config/bundler-audit.yml`)
- `bin/importmap audit` — JavaScript dependency vulnerability scanning

## Test Database

`storage/test.sqlite3` — separate from development DB, reset between test runs.

## Coverage

No coverage tooling configured (SimpleCov or similar not in Gemfile).

## Current State

**No domain tests exist yet.** The test suite structure is fully scaffolded but empty — all test directories contain only `.keep` files.
