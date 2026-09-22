#!/bin/bash
# Open psql inside the container. Usage: scripts/psql.sh [app|admin]
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a

if [[ "${1:-app}" == "admin" ]]; then
  docker compose exec postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
else
  docker compose exec postgres psql -U "$APP_DB_USER" -d "$APP_DB_NAME"
fi
