require "bundler/gem_tasks"
require "rspec/core/rake_task"

require File.expand_path('spec/rails_app/config/environment', __dir__)

Rails.application.load_tasks

RSpec::Core::RakeTask.new(:spec)

namespace :db do
  desc 'Create and set up the test database'
  task setup: :environment do
    puts 'Creating and loading schema for test database...'
    Rake::Task['db:create'].invoke
    Rake::Task['db:schema:load'].invoke
    puts 'Done.'
  end
end

task default: :spec
