# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Tigris handles contact form submissions for static Next.js client sites. Each organization (a website owner) gets API keys; their static site POSTs form submissions to Tigris, which stores them and emails the organization's members.

License: AGPL v3.

## Stack

- Rails 8.1, full-stack (not API-only), PostgreSQL
- HAML views, Tailwind CSS v4, esbuild, Propshaft, Hotwire (Turbo + Stimulus)
- Solid Queue / Solid Cache / Solid Cable (no Redis)
- Deployed via Capistrano → Puma, behind Nginx + Certbot on a VPS

## Development setup

```bash
bin/setup    # install deps, prepare DB, start dev server
bin/dev      # Rails server + Tailwind CSS watcher (Foreman)
```

Ruby: 4.0.3 (`.ruby-version`)

## Common commands

```bash
bin/rails db:migrate
bin/rails routes

bundle exec rspec                                    # full test suite
bundle exec rspec spec/path/to/file_spec.rb          # single file

bin/rubocop                  # lint (rubocop-rails-omakase)
bin/brakeman --no-pager      # static security analysis
bin/bundler-audit            # gem CVE audit

npm run build                # bundle JS (esbuild)
npm run build:css            # compile Tailwind CSS
```

## Architecture

### Multi-tenancy

The top-level tenant is `Organization`. All data (submissions, API keys) is scoped to an organization. Users belong to organizations through `Membership`. Enforce tenancy in every query by scoping through `current_organization` — never fetch by bare ID.

### Core models

- `User` — `has_secure_password`, email normalized to lowercase. Belongs to organizations through memberships.
- `Session` — belongs to User, stores ip_address and user_agent.
- `Organization` — top-level tenant. `has_many :memberships`, `has_many :users, through: :memberships`, `has_many :api_keys`, `has_many :submissions`.
- `Membership` — join between User and Organization. `role` string column: `"owner"` or `"member"`. No roles gem.
- `ApiKey` — belongs to Organization, holds a hashed token, revocable. Used to authenticate inbound form POSTs.
- `Submission` — belongs to Organization (resolved via API key lookup). Stores form payload (jsonb) and source metadata.

### Two authentication paths

1. **Session auth** (`rails generate authentication`) — for the customer-facing UI. The `Authentication` concern is included in `ApplicationController`. `Current` (ActiveSupport::CurrentAttributes) holds the session and user.
2. **API key auth** — for the public form submission endpoint. Requests carry the organization's API key in a header. A separate before-action resolves the key to an organization and sets rate limits via Rack::Attack. Session cookies play no role here.

These two paths are intentionally separate; do not conflate them.

### Form submission endpoint

Public-facing POST endpoint authenticated by API key (not session). Rate-limited per key via Rack::Attack. On success: save submission, enqueue email notification to the organization's members.

### Customer UI / admin

Organization members log in with session auth to view and manage their submissions. An admin interface (Administrate or simple scaffold — TBD) allows super-admin access. Not yet built.

### Not building (yet)

- OAuth / passkeys (future consideration)
- CMS or headless content API
- Anything beyond form handling

## Testing

RSpec (not Minitest). `use_transactional_fixtures` enabled. Specs live in `spec/`.

## CI (GitHub Actions)

Runs on every PR and push to `main`:
1. `scan_ruby` — Brakeman + bundler-audit
2. `lint` — RuboCop

No automated test job in CI yet.
