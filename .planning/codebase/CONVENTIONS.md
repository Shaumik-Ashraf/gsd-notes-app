---
last_mapped: 2026-05-18
---

# Code Conventions

## Style Enforcer

**RuboCop with `rubocop-rails-omakase`** — inherits Basecamp/Rails Omakase style. Config at `.rubocop.yml`. No overrides defined yet (file is default with commented examples).

Run: `bin/rubocop` — GitHub annotations format used in CI (`-f github`).

## Ruby Style (Omakase defaults)

Key Omakase conventions:
- Double quotes for strings
- Two-space indentation
- Trailing commas in multiline arrays/hashes
- `frozen_string_literal: true` not enforced by default
- No `and`/`or` keywords (use `&&`/`||`)
- Method parentheses omitted when unambiguous

## Rails Patterns

### Controllers

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  allow_browser versions: :modern   # Rejects IE and old browsers
  stale_when_importmap_changes       # Cache invalidation
end
```

New controllers should inherit from `ApplicationController`.

### Models

```ruby
# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

All models inherit from `ApplicationRecord`.

### Views / Templates

- ERB (`.html.erb`) for server-rendered HTML
- Jbuilder (`.json.jbuilder`) for JSON responses when needed
- No view components gem yet (plain partials expected)

### JavaScript

Stimulus controller pattern:
```javascript
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() { /* called when element enters DOM */ }
}
```

Controllers auto-discovered from `app/javascript/controllers/` via `index.js`. Named with `data-controller` attribute in HTML.

### Background Jobs

```ruby
class SomeJob < ApplicationJob
  queue_as :default
  def perform(*args) ... end
end
```

### Mailers

```ruby
class SomeMailer < ApplicationMailer
  default from: "from@example.com"
  ...
end
```

## Parameter Filtering

Sensitive params auto-filtered from logs (configured in `config/initializers/filter_parameter_logging.rb`):
- `:passw`, `:email`, `:secret`, `:token`, `:_key`, `:crypt`, `:salt`, `:certificate`, `:otp`, `:ssn`, `:cvv`, `:cvc`

## Error Handling

No custom error handling configured yet. Rails defaults apply:
- Public error pages in `public/` (400, 404, 406, 422, 500)
- `consider_all_requests_local = true` in development (full stack traces)

## Content Security Policy

CSP initializer exists at `config/initializers/content_security_policy.rb` but is fully commented out — no CSP enforced yet.

## Assets

- CSS: standard cascade, no preprocessor. One `application.css` manifest imports all stylesheets.
- Images: in `app/assets/images/`
- Vendored JS: `vendor/javascript/` for importmap-pinned packages
