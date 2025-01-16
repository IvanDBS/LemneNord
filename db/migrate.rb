require 'active_record'
require_relative '../config'

# Подключаемся к базе данных
ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)

# Создаем директорию для базы данных если её нет
require 'fileutils'
FileUtils.mkdir_p('db')

# Запускаем миграции
ActiveRecord::MigrationContext.new('db/migrate', ActiveRecord::SchemaMigration).migrate

puts "Migrations completed successfully!" 