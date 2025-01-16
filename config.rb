require 'dotenv/load'
require 'active_support/time'
require 'uri'

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
  DATABASE_CONFIG = begin
    if ENV['DATABASE_URL']
      # Парсим URL для проверки
      uri = URI.parse(ENV['DATABASE_URL'])
      puts "Using database URL: #{uri.scheme}://#{uri.host}:#{uri.port}/#{uri.path}"
      ENV['DATABASE_URL']
    else
      # Проверяем наличие необходимых переменных
      raise "Missing PGHOST" unless ENV['PGHOST']
      raise "Missing PGPORT" unless ENV['PGPORT']
      raise "Missing PGDATABASE" unless ENV['PGDATABASE']
      
      {
        adapter: 'postgresql',
        host: ENV['PGHOST'],
        database: ENV['PGDATABASE'],
        username: ENV['PGUSER'],
        password: ENV['PGPASSWORD'],
        port: ENV['PGPORT'],
        pool: ENV.fetch('DB_POOL', 10).to_i,
        timeout: ENV.fetch('DB_TIMEOUT', 3000).to_i
      }
    end
  end.freeze

  # Настройки планировщика
  SCHEDULER_CONFIG = {
    stats_time: '0 9 * * *'
  }.freeze
end 