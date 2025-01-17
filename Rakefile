require 'active_record'
require 'fileutils'
require_relative 'config'

namespace :db do
  desc "Run database migrations"
  task :migrate do
    begin
      puts "Starting database migration..."
      FileUtils.mkdir_p('db')
      
      ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)
      
      # Удаляем все таблицы
      conn = ActiveRecord::Base.connection
      tables = conn.tables
      tables.each do |table|
        puts "Dropping table: #{table}"
        conn.drop_table(table, force: :cascade)
      end
      puts "All tables dropped"
      
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