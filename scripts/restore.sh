#!/bin/bash
# Restore a pg_dumpall backup into the running container.
# Usage: scripts/restore.sh backups/pg_dumpall_YYYYmmdd_HHMMSS.sql.gz
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a

file="${1:?usage: $0 <backup.sql.gz>}"
[[ -f "$file" ]] || { echo "No such file: $file" >&2; exit 1; }

read -rp "Restore $file into container '${CONTAINER_NAME:-postgres}'? [y/N] " ok
[[ "$ok" == [yY] ]] || exit 1

gunzip -c "$file" | docker compose exec -T postgres psql -U "$POSTGRES_USER" -d postgres -v ON_ERROR_STOP=0
