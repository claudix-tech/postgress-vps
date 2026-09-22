# postgress-vps

PostgreSQL 18 in Docker, ready to run on a VPS.

## What you get

- `postgres:18-alpine` with SCRAM-SHA-256 auth, a healthcheck, `restart: unless-stopped` and log rotation
- Port bound to `127.0.0.1` by default, so it isn't reachable from the internet
- A superuser for admin work, plus a least-privilege **app role + database** created on first start
- Backup / restore / psql helper scripts

## Quick start

```bash
cp .env.example .env
# set strong passwords, e.g.:
sed -i "s/change-me-superuser/$(openssl rand -hex 24)/; s/change-me-app/$(openssl rand -hex 24)/" .env
chmod 600 .env

docker compose up -d --wait
scripts/psql.sh          # psql as the app user
scripts/psql.sh admin    # psql as superuser
```

App connection string (from the VPS host):

```
postgresql://$APP_DB_USER:$APP_DB_PASSWORD@127.0.0.1:5432/$APP_DB_NAME
```

Containers in other compose projects can reach it by joining this project's network, or through the host.

## Remote access

Leave `POSTGRES_BIND=127.0.0.1` and use an SSH tunnel:

```bash
ssh -N -L 5432:127.0.0.1:5432 user@your-vps
```

If you really need to expose it publicly, set `POSTGRES_BIND=0.0.0.0` **and** restrict the port with a firewall
(note: Docker-published ports bypass `ufw` rules by default, so use the `DOCKER-USER` iptables chain or the provider's firewall).

## Backups

```bash
scripts/backup.sh                                   # -> backups/pg_dumpall_<timestamp>.sql.gz
scripts/restore.sh backups/pg_dumpall_<ts>.sql.gz   # restore into the running container
```

`backup.sh` deletes backups older than `BACKUP_RETENTION_DAYS`. To run it nightly:

```
0 3 * * * /opt/postgress-vps/scripts/backup.sh >> /var/log/pg-backup.log 2>&1
```

Restore is meant for a **fresh** instance (new volume). Against an existing cluster, errors like "role already exists" are expected and harmless,
but tables that already exist won't be overwritten. Copy backups off the VPS too.

## Notes

- `initdb/` scripts run **only** when the data volume is empty. Changing `APP_DB_*` afterwards won't do anything, so create the role by hand.
- Data lives in the named volume `postgres_data`. `docker compose down` keeps it; `down -v` **deletes it**.
- Major version upgrades (e.g. 18 → 19) need a dump and restore, or `pg_upgrade`. Changing the image tag alone isn't enough.
