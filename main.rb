require 'fileutils'
require 'telegram/bot'
require 'active_record'
require_relative 'config'

# Создаем директории если их нет
FileUtils.mkdir_p('log')
FileUtils.mkdir_p('db')
FileUtils.mkdir_p('backups')

# Настраиваем логирование
logger = Logger.new('log/bot.log')
logger.level = Logger::INFO
ActiveRecord::Base.logger = logger

# Подключаем базу данных
ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)

# Загружаем все файлы
Dir["./lib/models/*.rb"].each { |file| require file }
Dir["./lib/bot/**/*.rb"].each { |file| require file }

# Запускаем миграции если таблиц нет
unless ActiveRecord::Base.connection.table_exists?('users')
  puts "Running migrations..."
  ActiveRecord::MigrationContext.new('db/migrate', ActiveRecord::SchemaMigration).migrate
  puts "Migrations completed!"
end

# Запускаем планировщик в отдельном процессе
fork do
  puts "Starting scheduler..."
  require_relative 'scheduler'
end

puts "Starting bot..."
Bot.new(Config::TELEGRAM_TOKEN, Config::ADMIN_IDS).start 