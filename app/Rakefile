%w{ bundler find rake/testtask}.each { |lib| require lib }

task :default => :spec

Rake::TestTask.new(:spec) do |t|
  t.test_files = FileList['spec/*_spec.rb']
end

namespace :db do
  desc "Run all migrations in db/migrations"
  task :migrate => :connect do
    Sequel.extension(:migration)
    Sequel::Migrator.apply(DB, "db/migrations")
  end

  task :connect => :environment do
    require "./db/connect"
  end
end

