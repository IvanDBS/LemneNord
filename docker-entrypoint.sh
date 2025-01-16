#!/bin/bash
set -e

until PGPASSWORD=$PGPASSWORD psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -c '\q'; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "Postgres is up - executing migrations"
bundle exec rake db:migrate

echo "Starting bot"
exec bundle exec ruby main.rb 