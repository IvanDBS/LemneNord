#!/bin/bash
set -e

echo "Waiting for PostgreSQL..."
until PGPASSWORD=$PGPASSWORD psql "postgresql://$PGUSER@$PGHOST:$PGPORT/$PGDATABASE" -c '\q' 2>/dev/null; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done

echo "PostgreSQL is up - executing migrations"
bundle exec rake db:migrate

echo "Starting bot"
exec bundle exec ruby main.rb 