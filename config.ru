require 'rubygems'
require 'bundler'

Bundler.require(:default)
require "./lib/shopify_endpoint"
run ShopifyEndpoint
