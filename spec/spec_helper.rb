ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rails_app/config/environment'
require 'rspec/rails'
require 'rails_log_book'
require 'factory_bot'
require 'pry'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
