require 'active_record'
require_relative 'config'
require 'fileutils'

namespace :db do
  desc "Run database migrations"
  task :migrate do
    begin
      puts "Starting database migration..."
      FileUtils.mkdir_p('db')
      
      # Очищаем схему
      FileUtils.rm_f('db/schema.rb')
      
      ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)
      
      # Сбрасываем таблицу schema_migrations
      ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS schema_migrations')
      ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS ar_internal_metadata')
      
      puts "Dropped old migration tables"
      
      # Запускаем миграции
      migrator = ActiveRecord::MigrationContext.new(
        "db/migrate/",
        ActiveRecord::SchemaMigration
      )
      
      migrator.migrate
      puts "Migrations completed successfully."
    rescue => e
      puts "Migration failed: #{e.message}"
      puts e.backtrace
      exit 1
    end
  end

  desc "Create database directory"
  task :create_dir do
    FileUtils.mkdir_p('db')
    puts "Created db directory."
  end

  desc "Setup database"
  task setup: [:create_dir, :migrate]
end 