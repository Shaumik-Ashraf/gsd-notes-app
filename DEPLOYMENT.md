# Deployment Guide

This app deploys via Kamal and Docker to a single Linux VPS running SQLite with Solid Queue, Solid Cache, and Solid Cable. No external databases or message brokers are required.

## Prerequisites

- Docker installed locally
- Kamal CLI: `gem install kamal` or `bundle exec kamal`
- SSH access to the target server (port 22, key-based auth recommended)
- A container registry account (Docker Hub, GitHub Container Registry, or DigitalOcean Registry)
- A Linux VPS reachable over SSH (Ubuntu 22.04 or Debian 12 recommended)
- The `RAILS_MASTER_KEY` from `config/master.key` (never committed — keep it safe)

## Encryption Keys

Active Record Encryption keys must exist in credentials before the app can boot.

1. Generate keys: `bin/rails db:encryption:init` — prints an `active_record_encryption:` YAML block
2. Open credentials: `EDITOR="nano" bin/rails credentials:edit`
3. Paste the generated block at the top level of the credentials file
4. Save and close — `config/credentials.yml.enc` is re-encrypted automatically
5. Verify: `bin/rails runner 'p Rails.application.credentials.dig(:active_record_encryption, :primary_key).present?'` — must print `true`

`config/master.key` must never be committed. Kamal delivers it to the server via the `RAILS_MASTER_KEY` secret.

## Container Registry Setup

Docker Hub:

```
docker login
```

GitHub Container Registry:

```
docker login ghcr.io -u YOUR_GITHUB_USERNAME -p YOUR_PERSONAL_ACCESS_TOKEN
```

Update `config/deploy.yml` with your registry hostname (see audit table below).

## Audit: deploy.yml Placeholders to Replace Before First Deploy

| Key | Current Value | Action Required |
|-----|---------------|-----------------|
| `servers.web` | `192.168.0.1` | Replace with your VPS IP or DNS name |
| `registry.server` | `localhost:5555` | Replace with your registry: `ghcr.io`, `registry.hub.docker.com`, etc. |
| `registry.username` | commented out | Uncomment and set your registry username |
| `registry.password` | commented out | Uncomment and set to `- KAMAL_REGISTRY_PASSWORD` (reads from .kamal/secrets) |
| `proxy.ssl` | commented out | Uncomment `ssl: true` and set `host:` to your public domain for Let's Encrypt SSL |
| `proxy.host` | `app.example.com` (in comment) | Set to your public hostname — must resolve on DNS before first deploy |
| `action_mailer.default_url_options.host` | `example.com` | Update in `config/environments/production.rb` to match your domain |

## Secrets and Environment Variables

Store secrets in `.kamal/secrets` (never commit this file):

```
RAILS_MASTER_KEY=<value from config/master.key>
KAMAL_REGISTRY_PASSWORD=<your registry access token>
# Only needed if using Gmail SMTP:
SMTP_USERNAME=<your gmail address>
SMTP_PASSWORD=<your Google App Password>
```

Kamal injects these as environment variables into the container at deploy time.

## Mailer Configuration

### Option A: Sendmail (simplest for a Linux VPS)

1. Install sendmail on the server: `sudo apt install sendmail`
2. Uncomment the Sendmail block in `config/environments/production.rb`
3. Redeploy: `bundle exec kamal deploy`

Sendmail sends from the VPS itself. Works well for low-volume transactional mail.

### Option B: Gmail SMTP

1. Create a Google App Password at myaccount.google.com/apppasswords
2. Add `SMTP_USERNAME` and `SMTP_PASSWORD` to `.kamal/secrets`
3. Uncomment the Gmail SMTP block in `config/environments/production.rb`
4. Redeploy: `bundle exec kamal deploy`

## First Deploy Command Sequence

1. `bundle exec kamal setup` — first time only; provisions Docker on the server, sets up registry login, deploys proxy and app
2. `bundle exec kamal deploy` — all subsequent deploys
3. `bundle exec kamal app logs -f` — verify the app booted cleanly
4. `bundle exec kamal console` — open a Rails console on the running app (needed to create users)

## Creating the First User

Self-registration is disabled. Users are created via the Rails console only:

```ruby
User.create!(email: "you@example.com", password: "longrandompassword")
```

Run this via `bundle exec kamal console` after the first deploy.

## Verifying the Running App

- `GET https://YOUR_HOST/up` — expect HTTP 200
- `GET https://YOUR_HOST/users/sign_in` — expect the styled sign-in page
- Open DevTools Network tab on any response and confirm these headers are present:
  - `X-Frame-Options: SAMEORIGIN`
  - `X-Content-Type-Options: nosniff`
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Content-Security-Policy: ... script-src 'self' ...`
  - `Strict-Transport-Security: ...` (set by Rails `force_ssl`)

## Common Issues

**App fails to boot: "Missing encryption configuration"**
Active Record Encryption keys are not in credentials. Run `bin/rails db:encryption:init`, paste the output into `bin/rails credentials:edit`, and redeploy.

**App fails to boot: "Missing secret_key_base" or similar**
`RAILS_MASTER_KEY` is not reaching the container. Verify `.kamal/secrets` contains `RAILS_MASTER_KEY=<value>` and that `config/deploy.yml` lists it under `env.secret`.

**Notes data lost after redeploy**
The SQLite storage volume is not persisted. Verify `config/deploy.yml` has the `volumes` entry pointing to a host path that survives container restarts (default: `gsd_notes_app_storage:/rails/storage`).
