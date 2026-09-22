#!/bin/bash
# Runs only on first init (empty data volume).
set -euo pipefail

if [[ -z "${APP_DB_NAME:-}" || -z "${APP_DB_USER:-}" || -z "${APP_DB_PASSWORD:-}" ]]; then
  echo "APP_DB_* not set, skipping application database creation"
  exit 0
fi

psql -v ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  -v app_user="$APP_DB_USER" -v app_password="$APP_DB_PASSWORD" -v app_db="$APP_DB_NAME" <<'SQL'
CREATE ROLE :"app_user" LOGIN PASSWORD :'app_password';
CREATE DATABASE :"app_db" OWNER :"app_user";
REVOKE ALL ON DATABASE :"app_db" FROM PUBLIC;
\connect :"app_db"
ALTER SCHEMA public OWNER TO :"app_user";
SQL

echo "Created database '$APP_DB_NAME' owned by '$APP_DB_USER'"
