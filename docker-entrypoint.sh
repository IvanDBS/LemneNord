#!/bin/bash
set -e

echo "PostgreSQL connection info:"
echo "Host: $PGHOST"
echo "Port: $PGPORT"
echo "Database: $PGDATABASE"
echo "User: $PGUSER"

# Проверяем и ждем доступности PostgreSQL
until PGPASSWORD=$PGPASSWORD psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -c '\q' 2>/dev/null
do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

echo "PostgreSQL is up - executing migrations"

# Запускаем миграции
bundle exec rake db:migrate

# Запускаем бота
echo "Starting bot"
ruby main.rb 