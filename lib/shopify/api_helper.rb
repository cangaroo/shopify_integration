module Shopify
  module APIHelper
    def api_get resource, data = {}
      params = ''
      unless data.empty?
        params = '?'
        data.each do |key, value|
          params += '&' unless params == '?'
          params += "#{key}=#{value}"
        end
      end

      throttle_api_calls

      response = RestClient.get shopify_url + (final_resource resource) + params
      JSON.parse response.force_encoding("utf-8")
    end

    def api_post resource, data
      throttle_api_calls

      response = RestClient.post shopify_url + resource, data.to_json,
        :content_type => :json, :accept => :json
      JSON.parse response.force_encoding("utf-8")
    end

    def api_put resource, data
      throttle_api_calls

      response = RestClient.put shopify_url + resource, data.to_json,
        :content_type => :json, :accept => :json
      JSON.parse response.force_encoding("utf-8")
    end

    def shopify_url
      "https://#{Util.shopify_apikey @config}:#{Util.shopify_password @config}" +
      "@#{Util.shopify_host @config}/admin/"
    end

    def final_resource resource
      if !@config['since'].nil?
        resource += ".json?updated_at_min=#{@config['since']}"
      elsif !@config['id'].nil?
        resource += "/#{@config['id']}.json"
      else
        resource += '.json'
      end
      resource
    end

    private

    def throttle_api_calls
      sleep Util.shopify_wait @config if Util.shopify_wait(@config).present?
    end
  end
end

