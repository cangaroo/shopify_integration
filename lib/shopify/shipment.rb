module Shopify
  class Shipment
    include APIHelper

    def initialize(payload, config)
      @shipment = payload
      @config = config
    end

    def ship!
      if @shipment['status'] == "shipped" && shopify_order_id
        begin
          api_post(
            "orders/#{shopify_order_id}/fulfillments.json",
            {
              fulfillment: { tracking_number: @shipment['tracking'],location_id: ENV.fetch('QUIET_SHOPIFY_LOCATION'),
              tracking_company: @shipment['carrier']}
            }
          )
        rescue RestClient::UnprocessableEntity
          if @fulfillment_status!= 'fulfilled'
            raise "Shipment #{@shipment['id']} could not be marked as shipped on Shopify!"
          end
        end

        "Updated shipment #{@shipment['id']} with tracking number #{@shipment['tracking']}."
      else
        raise "Order #{@shipment['order_id']} not found on Shopify" unless shopify_order_id
      end
    end

    def shopify_order_id
      @shopify_order_id ||= @shipment['shopify_order_id'] || find_order_id_by_order_number(@shipment['id'])
    end

    def find_order_id_by_order_number(order_number)
      if !order_number.nil?
          response = api_get 'orders',{name:order_number,status:'any'}

          response['orders'].each do |order|
            @fulfillment_status = order['fulfillment_status']
            return order['id'].to_s if  order['order_number'].to_s == order_number
          end
      end
      return nil
    end
  end
end