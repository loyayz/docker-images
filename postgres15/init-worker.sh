#!/bin/bash

set -e

# Create the worker user
CREATE_USER="CREATE USER $PG_WORK_USER WITH ENCRYPTED PASSWORD '$PG_WORK_PASSWORD'"
psql -U $POSTGRES_USER -tc "SELECT 1 FROM pg_user WHERE usename = '$PG_WORK_USER'" | grep -q 1 || psql -U $POSTGRES_USER -c "$CREATE_USER"

# Create the worker database
CREATE_DATABASE="CREATE DATABASE $PG_WORK_DATABASE WITH TEMPLATE template_db OWNER $PG_WORK_USER"
psql -U $POSTGRES_USER -tc "SELECT 1 FROM pg_database WHERE datname = '$PG_WORK_DATABASE'" | grep -q 1 || psql -U $POSTGRES_USER -c "$CREATE_DATABASE"
