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
      puts "Using database URL: #{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}"
      ENV['DATABASE_URL']
    else
      # Проверяем наличие необходимых переменных
      required_vars = %w[PGHOST PGPORT PGDATABASE PGUSER PGPASSWORD]
      missing_vars = required_vars.select { |var| ENV[var].nil? }
      
      if missing_vars.any?
        raise "Missing required PostgreSQL variables: #{missing_vars.join(', ')}"
      end
      
      config = {
        adapter: 'postgresql',
        host: ENV['PGHOST'],
        database: ENV['PGDATABASE'],
        username: ENV['PGUSER'],
        password: ENV['PGPASSWORD'],
        port: ENV['PGPORT'],
        pool: ENV.fetch('DB_POOL', 10).to_i,
        timeout: ENV.fetch('DB_TIMEOUT', 3000).to_i
      }
      
      puts "Using direct PostgreSQL connection to #{config[:host]}:#{config[:port]}/#{config[:database]}"
      config
    end
  end.freeze

  # Настройки планировщика
  SCHEDULER_CONFIG = {
    stats_time: '0 9 * * *'
  }.freeze
end 