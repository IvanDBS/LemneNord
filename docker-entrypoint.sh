#!/bin/bash
set -e

echo "PostgreSQL connection info:"
echo "Host: $PGHOST"
echo "Port: $PGPORT"
echo "Database: $PGDATABASE"
echo "User: $PGUSER"

echo "Waiting for PostgreSQL..."
until PGPASSWORD=$PGPASSWORD psql "postgresql://$PGUSER@$PGHOST:$PGPORT/$PGDATABASE" -c '\q' 2>/dev/null; do
  echo "PostgreSQL is unavailable - sleeping"
  # Проверяем доступность хоста
  nc -zv $PGHOST $PGPORT 2>/dev/null
  sleep 2
done

echo "PostgreSQL is up - executing migrations"
bundle exec rake db:migrate

echo "Starting bot"
exec bundle exec ruby main.rb 