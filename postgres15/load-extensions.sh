#!/bin/bash

set -e

# Create the template db
psql -U $POSTGRES_USER -tc "SELECT 1 FROM pg_database WHERE datname = 'template_db'" | grep -q 1 || psql -U $POSTGRES_USER -c "CREATE DATABASE template_db IS_TEMPLATE true"

# Load extensions into both template_db and $POSTGRES_DB
for DB in template_db "$POSTGRES_DB"; do
echo "Loading extensions extensions into $DB"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS pg_stat_monitor;
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis_topology;
    \c
    CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    CREATE EXTENSION IF NOT EXISTS hll;
    CREATE EXTENSION IF NOT EXISTS pg_repack;
    CREATE EXTENSION IF NOT EXISTS pgrouting;
    CREATE EXTENSION IF NOT EXISTS rum;
    SELECT extname,extversion FROM pg_extension;
EOSQL
done
