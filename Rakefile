require 'active_record'
require_relative 'config'

namespace :db do
  desc "Create the database"
  task :create do
    puts "Creating database..."
    `mkdir -p db`
    `touch db/bot.sqlite3`
    puts "Database created."
  end

  desc "Run database migrations"
  task :migrate do
    ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)
    ActiveRecord::MigrationContext.new('db/migrate', ActiveRecord::SchemaMigration).migrate
    puts 'Migrations completed!'
  end

  desc "Drop the database"
  task :drop do
    puts "Dropping database..."
    File.delete('db/bot.sqlite3') if File.exist?('db/bot.sqlite3')
    puts "Database dropped."
  end

  desc "Reset the database"
  task :reset => [:drop, :create, :migrate]
end 