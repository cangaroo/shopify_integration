module Factories
  def self.parameters
    {
      :shopify_apikey => ENV['SHOPIFY_APIKEY'], 
      :shopify_password => ENV['SHOPIFY_PASSWORD'], 
      :shopify_host => ENV['SHOPIFY_HOST'], 
      :shopify_wait => ENV['SHOPIFY_WAIT'], 
      :create_shipments => ENV['CREATE_SHIPMENTS']
    }
  end
end