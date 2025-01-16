require 'dotenv/load'
require 'active_support/time'

module Config
  # Устанавливаем временную зону
  Time.zone = 'Europe/Chisinau'
  
  # Токен бота
  TELEGRAM_TOKEN = ENV['TELEGRAM_BOT_TOKEN']

  # ID администраторов
  ADMIN_IDS = ENV['TELEGRAM_ADMIN_IDS'].split(',').map(&:to_i).freeze

  # ID канала
  CHANNEL_ID = ENV['TELEGRAM_CHANNEL_ID'].to_i

  # Конфигурация базы данных с значениями по умолчанию
  DATABASE_CONFIG = {
    adapter: ENV['DB_ADAPTER'] || 'postgresql',
    host: ENV['DB_HOST'],
    database: ENV['DB_NAME'],
    username: ENV['DB_USERNAME'],
    password: ENV['DB_PASSWORD'],
    port: ENV['DB_PORT'],
    pool: (ENV['DB_POOL'] || 10).to_i,
    timeout: (ENV['DB_TIMEOUT'] || 3000).to_i
  }.freeze

  # Настройки планировщика
  SCHEDULER_CONFIG = {
    # Время отправки статистики админам
    stats_time: '0 9 * * *'
  }.freeze
end 