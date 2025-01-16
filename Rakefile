require 'active_record'
require_relative 'config'
require 'fileutils'

namespace :db do
  desc "Run database migrations"
  task :migrate do
    begin
      puts "Starting database migration..."
      FileUtils.mkdir_p('db')
      
      # Очищаем схему и старые миграции
      FileUtils.rm_f('db/schema.rb')
      
      ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)
      
      # Проверяем существующие миграции
      migrator = ActiveRecord::MigrationContext.new(
        "db/migrate/",
        ActiveRecord::SchemaMigration
      )
      
      if migrator.needs_migration?
        migrator.migrate
        puts "Migrations completed successfully."
      else
        puts "No pending migrations."
      end
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