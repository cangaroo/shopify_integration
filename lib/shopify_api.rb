require 'json'
require 'rest-client'
require 'pp'

class ShopifyAPI
  include Shopify::APIHelper

  attr_accessor :order, :config, :payload, :request

  def initialize(payload, config = {})
    @payload = payload
    @config = config
  end

  def get_products
    inventories = []
    products = get_objs('products', Product)
    products.each do |product|
      next if product.variants.nil?

      product.variants.each do |variant|
        next if variant.sku.blank?

        inventory = Inventory.new
        inventory.add_obj variant
        inventories << inventory.wombat_obj
      end
    end

    {
      'objects' => Util.wombat_array(products),
      'message' => "Successfully retrieved #{products.length} products " +
        'from Shopify.'
      # ,'additional_objs' => inventories,
      # 'additional_objs_name' => 'inventory'
    }
  end

  def get_customers
    get_webhook_results 'customers', Customer
  end

  def get_inventory
    inventories = []
    get_objs('products', Product).each do |product|
      next if product.variants.nil?

      product.variants.each do |variant|
        next if variant.sku.blank?

        inventory = Inventory.new
        inventory.add_obj variant
        inventories << inventory.wombat_obj
      end
    end
    get_reply inventories, 'Retrieved inventories.'
  end

  def get_shipments
    shipments = []
    get_objs('orders', Order).each do |order|
      shipments += shipments(order.shopify_id)
    end
    get_webhook_results 'shipments', shipments, false
  end

  def get_orders
    get_webhook_results 'orders', Order
    orders = Util.wombat_array(get_objs('orders', Order))

    response = {
      'objects' => orders,
      'message' => "Successfully retrieved #{orders.length} orders " +
                   'from Shopify.'
    }

    # config to return corresponding shipments
    if @config[:create_shipments].to_i == 1
      shipments = []
      orders.each do |order|
        shipments << Shipment.wombat_obj_from_order(order)
      end

      response.merge({
                       'additional_objs' => shipments,
                       'additional_objs_name' => 'shipment'
                     })
    else
      response
    end
  end

  def add_product
    product = Product.new
    product.add_wombat_obj @payload['product'], self
    result = api_post 'products.json', product.shopify_obj

    {
      'objects' => result,
      'message' => 'Product added with Shopify ID of ' +
        "#{result['product']['id']} was added."
    }
  end

  def update_product
    product = Product.new
    product.add_wombat_obj @payload['product'], self

    ## Using shopify_obj_no_variants is a workaround until
    ## specifying variants' Shopify IDs is added
    master_result = api_put(
      "products/#{product.shopify_id}.json",
      product.shopify_obj_no_variants
    )

    product.variants.each do |variant|
      if variant_id = (variant.shopify_id || find_variant_shopify_id(product.shopify_id, variant.sku))
        api_put(
          "variants/#{variant_id}.json",
          variant.shopify_obj
        )
      else
        begin
          api_post("products/#{product.shopify_id}/variants.json", variant.shopify_obj)
        rescue RestClient::UnprocessableEntity
          # theres already a variant with same options, bail.
        end
      end
    end

    {
      'objects' => master_result,
      'message' => 'Product with Shopify ID of ' +
        "#{master_result['product']['id']} was updated."
    }
  end

  def add_customer
    customer = Customer.new
    customer.add_wombat_obj @payload['customer'], self
    result = api_post 'customers.json', customer.shopify_obj

    {
      'objects' => result,
      'message' => 'Customer with Shopify ID of ' +
        "#{result['customer']['id']} was added."
    }
  end

  def update_customer
    customer = Customer.new
    customer.add_wombat_obj @payload['customer'], self

    begin
      result = api_put "customers/#{customer.shopify_id}.json",
                       customer.shopify_obj
    rescue RestClient::UnprocessableEntity => e
      # retries without addresses to avoid duplication bug
      customer_without_addresses = customer.shopify_obj
      customer_without_addresses['customer'].delete('addresses')

      result = api_put "customers/#{customer.shopify_id}.json", customer_without_addresses
    end

    {
      'objects' => result,
      'message' => 'Customer with Shopify ID of ' +
        "#{result['customer']['id']} was updated."
    }
  end

  def set_inventory
    inventory = Inventory.new
    inventory.add_wombat_obj @payload['inventory']
    puts 'INV: ' + @payload['inventory'].to_json
    inventory_item_id = find_inventory_id_by_sku(inventory.sku)

    unless inventory_item_id.blank?
      message = "Set inventory of SKU #{inventory.sku} " +
                "to #{inventory.quantity}."
      begin
        message = 'Could not find item with SKU of ' + inventory.sku
        result = api_post 'inventory_levels/set.json', { 'location_id': ENV.fetch('QUIET_SHOPIFY_LOCATION'), 'inventory_item_id': inventory_item_id, 'available': inventory.quantity }
      rescue RestClient::UnprocessableEntity => e
        result = api_put "inventory_items/#{inventory_item_id}.json", { "inventory_item": { "id": inventory_item_id, "tracked": true } }
        result = api_post 'inventory_levels/set.json', { 'location_id': ENV.fetch('QUIET_SHOPIFY_LOCATION'), 'inventory_item_id': inventory_item_id, 'available': inventory.quantity }
      end
    end
    {
      'objects' => result,
      'message' => message
    }
  end

  def add_metafield(obj_name, shopify_id, _wombat_id)
    api_obj_name = (obj_name == 'inventory' ? 'product' : obj_name)

    api_post "#{api_obj_name}s/#{shopify_id}/metafields.json",
             Metafield.new(@payload[obj_name]['id']).shopify_obj
  end

  def wombat_id_metafield(obj_name, shopify_id)
    wombat_id = nil

    api_obj_name = (obj_name == 'inventory' ? 'product' : obj_name)

    metafields_array = api_get "#{api_obj_name}s/#{shopify_id}/metafields"
    unless metafields_array.nil? || metafields_array['metafields'].nil?
      metafields_array['metafields'].each do |metafield|
        if metafield['key'] == 'wombat_id'
          wombat_id = metafield['value']
          break
        end
      end
    end

    wombat_id
  end

  def order(order_id)
    get_objs "orders/#{order_id}", Order
  end

  def transactions(order_id)
    get_objs "orders/#{order_id}/transactions", Transaction
  end

  def shipments(order_id)
    get_objs "orders/#{order_id}/fulfillments", Shipment
  end

  private

  def get_webhook_results(obj_name, obj, get_objs = true)
    objs = Util.wombat_array(get_objs ? get_objs(obj_name, obj) : obj)
    get_reply objs, "Successfully retrieved #{objs.length} #{obj_name} " +
                    'from Shopify.'
  end

  def get_reply(objs, message)
    {
      'objects' => objs,
      'message' => message
    }
  end

  def get_objs(objs_name, obj_class)
    objs = []

    params = {}

    if @payload['last_poll'].present?
      lastrun = Time.at(@payload['last_poll']) - 30.seconds
      # utc params[:updated_at_min] = Time.at(lastrun).to_s(:iso8601)
      params[:updated_at_min] = Time.at(lastrun).in_time_zone('Eastern Time (US & Canada)').to_s(:iso8601)
      # limit to only newish objects
      # params[:created_at_min] = (DateTime.now-30).in_time_zone('Eastern Time (US & Canada)').to_s(:iso8601)
    end

    sleep(0.3)

    # get first record set

    params.merge!(fulfillment_status: 'unfulfilled') if objs_name.start_with?('orders')
    params.merge!(limit: 250)

    more_data = true
    while more_data

      shopify_objs = if link.nil?
                       api_get objs_name, params
                     else api_get objs_name, { link: link }
                     end

      link = shopify_objs.to_h['link']
      more_data = !link.nil?

      if shopify_objs.values.first.is_a?(Array)
        shopify_objs.values.first.each do |shopify_obj|
          obj = obj_class.new
          obj.add_shopify_obj shopify_obj, self
          objs << obj
        end
      else
        obj = obj_class.new
        obj.add_shopify_obj shopify_objs.values.first, self
        objs << obj
      end

    end
    objs
  end

  def find_variant_shopify_id(product_shopify_id, variant_sku)
    variants = api_get("products/#{product_shopify_id}/variants")['variants']

    if variant = variants.find { |v| v['sku'] == variant_sku }
      variant['id']
    end
  end

  def find_product_shopify_id_by_sku(sku)
    count = (api_get 'products/count')['count']
    page_size = 250
    pages = (count / page_size.to_f).ceil
    current_page = 1

    while current_page <= pages
      products = api_get 'products',
                         { 'limit' => page_size, 'page' => current_page }
      current_page += 1
      products['products'].each do |product|
        product['variants'].each do |variant|
          return variant['id'].to_s if variant['sku'] == sku
        end
      end
    end

    nil
  end
end

def find_inventory_id_by_sku(sku)
  count = (api_get 'products/count')['count']
  page_size = 250
  pages = (count / page_size.to_f).ceil
  current_page = 1

  while current_page <= pages
    products = api_get 'products',
                       { 'limit' => page_size, 'page' => current_page }
    current_page += 1
    products['products'].each do |product|
      product['variants'].each do |variant|
        return variant['inventory_item_id'].to_s if variant['sku'] == sku
      end
    end
  end

  nil
end

class AuthenticationError < StandardError; end
class ShopifyError < StandardError; end
