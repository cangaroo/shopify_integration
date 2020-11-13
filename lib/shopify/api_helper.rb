module Shopify
  module APIHelper
    def api_get(resource, data = {})
      params = ''
      unless data.empty?
        params = '?'
        data.each do |key, value|
          if key.to_s == 'link'
            then params = "?#{value}"
                 break
          else
            params += '&' unless params == '?'
            params += "#{key}=#{value}"
          end
        end
      end
      response = RestClient.get shopify_url + (final_resource resource) + params
      res = JSON.parse response.force_encoding('utf-8')
      links = response.headers.to_h[:link]&.split(',', 2)
      link = nil
      unless links.nil?
        link = if links&.first&.include?('next')
                 links&.first&.split('?', 2)&.second.gsub('"', '').gsub('>', '')
               elsif links&.second&.include?('next')
                 links&.second&.split('?', 2)&.second.gsub('"', '').gsub('>', '')
               end
      end
      res.merge('link' => link)
    end

    def api_post(resource, data)
      response = RestClient.post shopify_url + resource, data.to_json,
                                 content_type: :json, accept: :json
      JSON.parse response.force_encoding('utf-8')
    end

    def api_put(resource, data)
      response = RestClient.put shopify_url + resource, data.to_json,
                                content_type: :json, accept: :json
      JSON.parse response.force_encoding('utf-8')
    end

    def shopify_url
      "https://#{Util.shopify_apikey @config}:#{Util.shopify_password @config}" +
        "@#{Util.shopify_host @config}/admin/api/#{Util.shopify_version @config}/"
    end

    def final_resource(resource)
      resource += if !@config['since'].nil?
                    ".json?updated_at_min=#{@config['since']}"
                  elsif !@config['id'].nil?
                    "/#{@config['id']}.json"
                  else
                    '.json'
                  end
      resource
    end
  end
end
