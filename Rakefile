require "bundler/gem_tasks"
require "rspec/core/rake_task"

require File.expand_path('spec/rails_app/config/environment', __dir__)

Rails.application.load_tasks

RSpec::Core::RakeTask.new(:spec)

task default: :spec
