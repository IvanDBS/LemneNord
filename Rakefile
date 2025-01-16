require 'active_record'
require_relative 'config'

namespace :db do
  desc "Run database migrations"
  task :migrate do
    ActiveRecord::Base.establish_connection(Config::DATABASE_CONFIG)
    ActiveRecord::MigrationContext.new(
      "db/migrate/",
      ActiveRecord::SchemaMigration
    ).migrate
    puts "Migrations completed."
  end

  desc "Create database directory"
  task :create_dir do
    FileUtils.mkdir_p('db')
    puts "Created db directory."
  end

  desc "Setup database"
  task setup: [:create_dir, :migrate]
end 