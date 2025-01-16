require 'telegram/bot'
require 'active_record'
require_relative 'config'
require_relative 'lib/bot/base'

begin
  puts "Starting bot..."
  
  # Подключаемся к БД
  ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)
  puts "Database connected"

  # Запускаем планировщик
  require_relative 'scheduler'
  puts "Starting scheduler..."

  # Запускаем бота
  bot = Bot::Base.new(Config::TELEGRAM_TOKEN, Config::ADMIN_IDS)
  bot.start
rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace
  
  # Пробуем переподключиться к БД если это ошибка соединения
  if e.is_a?(ActiveRecord::ConnectionNotEstablished)
    retry
  end
  
  exit 1
end 