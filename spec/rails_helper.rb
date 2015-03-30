ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'pry'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include Warden::Test::Helpers
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.include BackgroundJobs
  config.include Capybara::Angular::DSL, type: :feature
  config.before(:each, type: :feature) { require Rails.root.join 'db', 'seeds' }
  config.before :suite do
    Warden.test_mode!
  end
end
Capybara.javascript_driver = :webkit
