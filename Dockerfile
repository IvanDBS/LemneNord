FROM ruby:3.2.2

# Установка PostgreSQL клиента и wait-for-it
RUN apt-get update -qq && \
    apt-get install -y postgresql-client wait-for-it

# Создание рабочей директории
WORKDIR /app

# Копирование Gemfile и установка гемов
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Копирование всего кода
COPY . .

# Создание нужных директорий и установка прав
RUN mkdir -p db log tmp backups && \
    chmod -R 777 db log tmp backups

# Ждем доступности PostgreSQL и затем запускаем миграции и бот
CMD wait-for-it ${PGHOST}:${PGPORT} -t 60 -- bundle exec rake db:migrate && bundle exec ruby main.rb 