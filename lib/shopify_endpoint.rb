require "sinatra"
require "endpoint_base"
require "require_all"

require_all File.dirname(__FILE__)

class ShopifyEndpoint < EndpointBase::Sinatra::Base

 post '/update_shipment' do
    summary = Shopify::Shipment.new(@payload['shipment'], @config).ship!
    result 200, summary
  end

  ## Supported endpoints:
  ## get_ for orders, products, inventories, shipments, customers
  ## add_ for product, customer
  ## update_ for product, customer
  ## set_inventory


  post '/get_unfulfilledorders' do
    action='get_orders'
    obj_name='shipments'
    shopify_action "#{action}", obj_name.singularize
  end

  post '/get_products' do
    action='get_products'
    obj_name='products'
    shopify_action "#{action}", obj_name.singularize
  end

  private

    def shopify_action action, obj_name
      begin
        action_type = action.split('_')[0]

        ## Add and update shouldn't come with a shopify_id, therefore when
        ## they do, it indicates Wombat resending an object.
        if wombat_resend_add?(action_type, obj_name) ||
             update_without_shopify_id?(action_type, obj_name)
           return result 200
        end

        shopify = ShopifyAPI.new(@payload, @config)
        response  = shopify.send(action)

        case action_type
          when 'get'
          response['objects'].each do |obj|
            ## Add object to Wombat
            add_object obj_name, obj
          end

          add_value obj_name.pluralize, [] if response['objects'].empty?

          add_parameter 'since', Time.now.utc.iso8601

        when 'add'
          ## This will do a partial update in Wombat, only the new key
          ## shopify_id will be added, everything else will be the same
          add_object obj_name,
                     { 'id' => @payload[obj_name]['id'],
                       'shopify_id' => response['objects'][obj_name]['id'].to_s }

          ## Add metafield to track Wombat ID
          shopify.add_metafield obj_name,
                                response['objects'][obj_name]['id'].to_s,
                                @payload[obj_name]['id']
          end

        if response.has_key?('additional_objs') &&
           response.has_key?('additional_objs_name')
          response['additional_objs'].each do |obj|
            add_object response['additional_objs_name'], obj
          end
        end

        # avoids "Successfully retrieved 0 customers from Shopify."
        if skip_summary?(response, action_type)
          return result 200
        else
          return result 200, response['message']
        end
      rescue => e
        print e.cause
        print e.backtrace.join("\n")
        result 500, (e.try(:response) ? e.response : e.message)
      end
    end

    def wombat_resend_add?(action_type, obj_name)
      action_type == 'add' && !@payload[obj_name]['shopify_id'].nil?
    end

    def update_without_shopify_id?(action_type, obj_name)
      action_type == 'update' && @payload[obj_name]['shopify_id'].nil? && obj_name != "shipment"
    end

    def skip_summary?(response, action_type)
      response['message'].nil? || get_without_objects?(response, action_type)
    end

    def get_without_objects?(response, action_type)
      action_type == 'get' && response['objects'].to_a.size == 0
    end
end