# CLAUDE.md

Docker Compose setup for a single PostgreSQL 18 instance meant for a VPS.

## Layout
- `docker-compose.yml`: the `postgres` service. Everything is configured through `.env` (template: `.env.example`).
- `initdb/`: first-init scripts (run only on an empty volume). `01-create-app-db.sh` creates the app role and DB from `APP_DB_*`.
- `scripts/`: `backup.sh` (pg_dumpall + gzip + retention), `restore.sh`, `psql.sh [app|admin]`.
- `backups/`: local dump output, git-ignored.

## Commands
- Start / status: `docker compose up -d --wait`, `docker compose ps`
- Logs: `docker compose logs -f postgres`
- Validate config: `docker compose config -q`

## Conventions
- Never commit `.env` or backups. Add new settings to `.env.example` with a safe default.
- Default port binding stays `127.0.0.1`. Don't change that default.
- Postgres 18+ images mount the volume at `/var/lib/postgresql` (not `/var/lib/postgresql/data`).
- Never run `docker compose down -v` unless explicitly asked, because it deletes the database.
