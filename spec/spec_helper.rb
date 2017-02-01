ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rails_app/config/environment'
require 'rspec/rails'
require 'log_book'
require 'pry'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.after(:each) do
    RequestStore.clear!
  end
end
