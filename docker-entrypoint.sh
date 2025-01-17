#!/bin/bash
set -e

# Ждем доступности PostgreSQL
until nc -z -v -w30 $PGHOST $PGPORT
do
  echo "Waiting for PostgreSQL..."
  sleep 1
done
echo "PostgreSQL is up - executing migrations"

# Запускаем миграции
bundle exec rake db:migrate

# Запускаем бота
echo "Starting bot"
ruby main.rb 