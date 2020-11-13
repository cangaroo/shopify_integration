Gem::Specification.new do |s|
  s.name  = "shopify_endpoint"
  s.version = "0.0.1"

  s.summary = "Cangaroo endpoint for Shopify"
  s.description = ""

  s.authors = ["Joe Lind"]
  s.email = "joe@shopfollain.com"
  s.homepage = "http://shopfollain.com"

  s.files = ([`git ls-files lib/`.split("\n")]).flatten

  s.test_files = `git ls-files spec/`.split("\n")

  s.add_runtime_dependency 'shopify'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'tilt'
  s.add_runtime_dependency 'tilt-jbuilder'
  s.add_runtime_dependency 'rest-client'
  s.add_runtime_dependency 'require_all'
end
