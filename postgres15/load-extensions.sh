#!/bin/bash

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the template db
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'template_db'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE template_db IS_TEMPLATE true"

# Load extensions into both template_db and $POSTGRES_DB
for DB in template_db "$POSTGRES_DB"; do
	echo "Loading extensions extensions into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'
	    CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
	    CREATE EXTENSION IF NOT EXISTS postgis;
	    CREATE EXTENSION IF NOT EXISTS postgis_topology;
	    \c
	    CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
	    CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL
done
