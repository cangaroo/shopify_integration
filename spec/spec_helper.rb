require 'rubygems'
require 'bundler'
require 'sinatra'
require 'dotenv'
Dotenv.load

Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'shopify_integration.rb')

Dir['./spec/support/**/*.rb'].each &method(:require)

require 'spree/testing_support/controllers'

Sinatra::Base.environment = 'test'

ENV['SHOPIFY_APIKEY'] ||= '123'
ENV['SHOPIFY_PASSWORD'] ||= 'passwd'
ENV['SHOPIFY_HOST'] ||= 'shop.myshopify.com'
ENV['SHOPIFY_WAIT'] ||= '0.5'
ENV['CREATE_SHIPMENTS'] ||= '1'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock

  # c.force_utf8_encoding = true

  c.filter_sensitive_data("SHOPIFY_APIKEY") { ENV["SHOPIFY_APIKEY"] }
  c.filter_sensitive_data("SHOPIFY_PASSWORD") { ENV["SHOPIFY_PASSWORD"] }
  c.filter_sensitive_data("SHOPIFY_HOST") { ENV["SHOPIFY_HOST"] }
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers

  config.order = 'random'
end
