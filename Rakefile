require 'active_record'
require 'dotenv/load'
require_relative 'config'

namespace :db do
  desc "Run database migrations"
  task :migrate => :environment do
    puts "Starting database migration..."
    ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)
    
    # Удаляем все таблицы перед миграцией
    puts "Dropping all tables..."
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table, force: :cascade)
    end
    puts "All tables dropped"
    
    # Запускаем миграции
    ActiveRecord::Migration.verbose = true
    ActiveRecord::MigrationContext.new(
      "db/migrate",
      ActiveRecord::SchemaMigration
    ).migrate
    
    puts "\nMigrations completed successfully."
  end

  desc "Create the database"
  task :create => :environment do
    begin
      connection_config = Config::DATABASE_CONFIG.merge('database' => 'postgres')
      ActiveRecord::Base.establish_connection(connection_config)
      ActiveRecord::Base.connection.create_database(Config::DATABASE_CONFIG['database'])
    rescue ActiveRecord::DatabaseAlreadyExists
      puts "Database already exists"
    end
  end

  desc "Drop the database"
  task :drop => :environment do
    begin
      connection_config = Config::DATABASE_CONFIG.merge('database' => 'postgres')
      ActiveRecord::Base.establish_connection(connection_config)
      ActiveRecord::Base.connection.drop_database(Config::DATABASE_CONFIG['database'])
    rescue ActiveRecord::DatabaseDoesNotExist
      puts "Database does not exist"
    end
  end
end

task :environment do
  require_relative 'config'
end 