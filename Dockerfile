FROM ruby:3.2.2

# Установка необходимых зависимостей
RUN apt-get update -qq && apt-get install -y sqlite3 libsqlite3-dev

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

# Запуск миграций и бота
CMD bundle exec rake db:migrate && bundle exec ruby main.rb 