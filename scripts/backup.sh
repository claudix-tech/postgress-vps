#!/bin/bash
# Dump every database (roles included) to a gzipped file and prune old backups.
# Cron example: 0 3 * * * /path/to/postgress-vps/scripts/backup.sh >> /var/log/pg-backup.log 2>&1
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a

BACKUP_DIR="${BACKUP_DIR:-./backups}"
RETENTION="${BACKUP_RETENTION_DAYS:-7}"
mkdir -p "$BACKUP_DIR"
file="$BACKUP_DIR/pg_dumpall_$(date +%Y%m%d_%H%M%S).sql.gz"

docker compose exec -T postgres pg_dumpall -U "$POSTGRES_USER" | gzip > "$file.tmp"
mv "$file.tmp" "$file"
echo "Backup written: $file ($(du -h "$file" | cut -f1))"

find "$BACKUP_DIR" -name 'pg_dumpall_*.sql.gz' -mtime +"$RETENTION" -print -delete
