require 'bundler/setup'
Bundler.setup

require 'glassguide' # and any other gems you need

RSpec.configure do |config|
  # some (optional) config here

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:',
  )
  require 'schema'
  # :password => "easyapi",
  # :database => "easyapi_dev"
  # :username => "easyapi",

  # config.include FactoryGirl::Syntax::Methods

  config.run_all_when_everything_filtered = true

  # config.before(:suite) do
  #   DatabaseCleaner.clean_with(:truncation)
  # end

  # config.before(:each) do
  #   DatabaseCleaner.strategy = :transaction
  # end

  # config.before(:each) do
  #   DatabaseCleaner.start
  # end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end

end