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
    adapter: 'sqlite3',
    database: 'db/bot.sqlite3',
    pool: ENV.fetch('DB_POOL', 10).to_i,
    timeout: ENV.fetch('DB_TIMEOUT', 3000).to_i
  }.freeze

  # Настройки планировщика
  SCHEDULER_CONFIG = {
    stats_time: '0 9 * * *'
  }.freeze
end 