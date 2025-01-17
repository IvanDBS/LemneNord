require 'telegram/bot'
require 'active_record'
require_relative 'config'
require_relative 'lib/bot/base'

puts "Loading models..."
Dir[File.join(__dir__, 'lib', 'models', '*.rb')].each do |file|
  puts "Loading model: #{file}"
  require file
end
puts "Models loaded"

begin
  puts "Starting bot with token: #{Config::TELEGRAM_TOKEN[0..5]}..."  # Only show first 6 chars for security
  puts "Admin IDs configured: #{Config::ADMIN_IDS.inspect}"
  puts "Channel ID configured: #{Config::CHANNEL_ID}"
  
  # Подключаемся к БД
  puts "Connecting to database at #{ENV['PGHOST']}:#{ENV['PGPORT']}/#{ENV['PGDATABASE']}"
  ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)
  puts "Testing database connection..."
  ActiveRecord::Base.connection.execute("SELECT 1")
  puts "Database connection test successful"
  
  # Проверяем наличие таблиц
  puts "Checking database tables..."
  puts "Users table exists: #{ActiveRecord::Base.connection.table_exists?('users')}"
  puts "Applications table exists: #{ActiveRecord::Base.connection.table_exists?('applications')}"

  # Запускаем планировщик
  require_relative 'scheduler'
  puts "Starting scheduler..."

  # Запускаем бота
  puts "Initializing bot..."
  bot = Bot::Base.new(Config::TELEGRAM_TOKEN, Config::ADMIN_IDS)
  puts "Starting bot listener..."
  bot.start
rescue => e
  puts "CRITICAL ERROR: #{e.message}"
  puts "Error class: #{e.class}"
  puts e.backtrace
  
  # Пробуем переподключиться к БД если это ошибка соединения
  if e.is_a?(ActiveRecord::ConnectionNotEstablished)
    puts "Database connection lost, retrying..."
    retry
  end
  
  exit 1
end 