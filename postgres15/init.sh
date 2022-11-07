#!/bin/bash

set -e

TEMPLATE_DB=template_db

# Create the template db
psql -U $POSTGRES_USER -tc "SELECT 1 FROM pg_database WHERE datname = '$TEMPLATE_DB'" \
    | grep -q 1 || psql -U $POSTGRES_USER -c "CREATE DATABASE $TEMPLATE_DB IS_TEMPLATE true"

# Load extensions into both template_db and $POSTGRES_DB
for DB in "$TEMPLATE_DB" "$POSTGRES_DB"; do
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

# Create work user and database
if [ -n $PG_WORK_USER ]; then
  echo "Create work user: $PG_WORK_USER"
  if [ -z $PG_WORK_PASSWORD ]; then
  		cat >&2 <<-'EOE'
  			Error: Worker password is not specified.
  			       You must specify PG_WORK_PASSWORD to a non-empty value for the worker.
  			       For example, "-e PG_WORK_PASSWORD=password" on "docker run".
  		EOE
  		exit 1
  	fi

  psql -U $POSTGRES_USER -tc "SELECT 1 FROM pg_user WHERE usename = '$PG_WORK_USER'" \
      | grep -q 1 || psql -U $POSTGRES_USER -c "CREATE USER $PG_WORK_USER WITH ENCRYPTED PASSWORD '$PG_WORK_PASSWORD'"

  if [ -n $PG_WORK_DB ]; then
    echo "Create work database: $PG_WORK_DB"
    psql -U $POSTGRES_USER -tc "SELECT 1 FROM pg_database WHERE datname = '$PG_WORK_DB'" \
        | grep -q 1 || psql -U $POSTGRES_USER -c "CREATE DATABASE $PG_WORK_DB WITH TEMPLATE $TEMPLATE_DB OWNER $PG_WORK_USER"
  fi
fi
