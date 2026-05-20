# GSD Notes App

[![CI](https://github.com/Shaumik-Ashraf/gsd-notes-app/actions/workflows/ci.yml/badge.svg)](https://github.com/Shaumik-Ashraf/gsd-notes-app/actions/workflows/ci.yml)

A note-taking app mockup built using [GSD](https://github.com/gsd-build/get-shit-done) AI paradigm.

## Dependencies

- Ruby 4.0.1
- Docker (for production only)

## Cold Start

1. Install dependencies

```
bin/bundle install
```

2. Create your own master key:

```
rm config/credentials.yml.enc
EDITOR=<editor> bin/rails credentials:edit
```

3. Setup [Active Record Encryption](https://guides.rubyonrails.org/active_record_encryption.html#generate-encryption-key).

4. Then proceed to Dev Start or Prod Start.

## Dev Start

1. `bin/rails server`

See `bin/` for suite of dev tools.

## Prod Start

1. docker build -t gsd_notes_app .

2. docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name gsd_notes_app gsd_notes_app

See [Kamal](https://kamal-deploy.org/) for proper deployment instructions.

## License

See [./LICENSE](./LICENSE).

## Stack

- Rails 8.1
- SQLite3
- Importmap
