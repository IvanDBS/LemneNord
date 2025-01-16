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
  DATABASE_CONFIG = if ENV['DATABASE_URL']
    # Используем URL из Railway
    ENV['DATABASE_URL']
  else
    # Локальная конфигурация
    {
      adapter: 'postgresql',
      host: ENV.fetch('PGHOST', 'localhost'),
      database: ENV.fetch('PGDATABASE', 'bot_development'),
      username: ENV.fetch('PGUSER', 'postgres'),
      password: ENV.fetch('PGPASSWORD', ''),
      port: ENV.fetch('PGPORT', 5432),
      pool: ENV.fetch('DB_POOL', 10).to_i,
      timeout: ENV.fetch('DB_TIMEOUT', 3000).to_i
    }
  end.freeze

  # Настройки планировщика
  SCHEDULER_CONFIG = {
    # Время отправки статистики админам
    stats_time: '0 9 * * *'
  }.freeze
end 