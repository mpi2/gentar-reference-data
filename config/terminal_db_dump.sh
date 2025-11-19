#!/bin/bash
set -e

pg_dump --clean --if-exists --no-comments --encoding=UTF8 -d "$POSTGRES_DB" -U "$POSTGRES_USER" > /usr/local/data/database.sql
chmod 755 /usr/local/data/database.sql