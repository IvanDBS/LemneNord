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

  # Конфигурация базы данных
  DATABASE_CONFIG = {
    adapter: ENV['DB_ADAPTER'],
    database: ENV['DB_NAME'],
    pool: ENV['DB_POOL'].to_i,
    timeout: ENV['DB_TIMEOUT'].to_i,
    checkout_timeout: 3
  }.freeze

  # Настройки планировщика
  SCHEDULER_CONFIG = {
    # Время отправки статистики админам
    stats_time: '0 9 * * *'
  }.freeze
end 