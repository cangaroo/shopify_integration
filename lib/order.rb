class Order

  attr_reader :shopify_id, :email, :shipping_address, :billing_address

  def add_shopify_obj shopify_order, shopify_api
    @store_name = Util.shopify_host(shopify_api.config).split('.')[0]
    @order_number = shopify_order['order_number']
    @shopify_id = shopify_order['id']
    @fulfillment_status=shopify_order['fulfillment_status']
    @financial_status=shopify_order['financial_status']
    @tags=shopify_order['tags']
    @test = shopify_order['test']
    @source = Util.shopify_host shopify_api.config
    @status = 'completed'
    @email = shopify_order['email']
    @currency = shopify_order['currency']
    @location_id = shopify_order['location_id']
    @source_identifier = shopify_order['source_identifier']
    @source_name = shopify_order['source_name']
    @placed_on = shopify_order['created_at']
    @totals_item = shopify_order['total_line_items_price'].to_f
    @totals_tax = shopify_order['total_tax'].to_f
    @totals_discounts = -1 * shopify_order['total_discounts'].to_f
    @totals_shipping = 0.00
    shopify_order['shipping_lines'].each do |shipping_line|
      @totals_shipping += shipping_line['price'].to_f
    end
    @payments = Array.new
    @totals_payment = 0.00
    shopify_api.transactions(@shopify_id).each do |transaction|
      if (transaction.kind == 'capture' or transaction.kind == 'sale') and
          transaction.status == 'success'
        @totals_payment += transaction.amount.to_f
        payment = Payment.new
        @payments << payment.add_shopify_obj(transaction, shopify_api, shopify_order)
      end
    end
    @totals_order = shopify_order['total_price'].to_f
    @line_items = Array.new
    shopify_order['line_items'].each do |shopify_li|
      line_item = LineItem.new
      @line_items << line_item.add_shopify_obj(shopify_li, shopify_api)
    end

    @shipping_method = (shopify_order['shipping_lines'].first || {})['code']

    unless shopify_order['shipping_address'].nil?
      @shipping_address = {
        'firstname' => shopify_order['shipping_address']['first_name'],
        'lastname' => shopify_order['shipping_address']['last_name'],
        'address1' => shopify_order['shipping_address']['address1'],
        'address2' => shopify_order['shipping_address']['address2'],
        'zipcode' => shopify_order['shipping_address']['zip'],
        'city' => shopify_order['shipping_address']['city'],
        'state' => shopify_order['shipping_address']['province'],
        'country' => shopify_order['shipping_address']['country_code'],
        'phone' => shopify_order['shipping_address']['phone']
      }
    end

    unless shopify_order['billing_address'].nil?
      @billing_address = {
        'firstname' => shopify_order['billing_address']['first_name'],
        'lastname' => shopify_order['billing_address']['last_name'],
        'address1' => shopify_order['billing_address']['address1'],
        'address2' => shopify_order['billing_address']['address2'],
        'zipcode' => shopify_order['billing_address']['zip'],
        'city' => shopify_order['billing_address']['city'],
        'state' => shopify_order['billing_address']['province'],
        'country' => shopify_order['billing_address']['country_code'],
        'phone' => shopify_order['billing_address']['phone']
      }
    end

    self
  end

  def wombat_obj
    {
      'id' => @shopify_id.to_s,
      'order_number' => @order_number.to_s,
      'shopify_id' => @shopify_id.to_s,
      'location_id' => @location_id,
      'source_identifier' => @source_identifier,
      'source_name' => @source_name,
      'fulfillment_status' => @fulfillment_status,
      'financial_status' => @financial_status,
      'test'=>@test,
      'tags'=>@tags,
      'source' => @source,
      'channel' => 'Shopify',
      'status' => @status,
      'email' => @email,
      'currency' => @currency,
      'placed_on' => @placed_on,
      'totals' => {
        'item' => @totals_item,
        'tax' => @totals_tax,
        'shipping' => @totals_shipping,
        'payment' => @totals_payment,
        'order' => @totals_order
      },
      'items' => Util.wombat_array(@line_items),
      'shipping_method' => @shipping_method,
      'adjustments' => [
        {
          'name' => 'Tax',
          'value' => @totals_tax
        },
        {
          'name' => 'Shipping',
          'value' => @totals_shipping
        },
        {
          'name' => 'Discounts',
          'value' => @totals_discounts
        }
      ],
      'shipping_address' => @shipping_address,
      'billing_address' => @billing_address,
      'payments' => Util.wombat_array(@payments)
    }
  end

end
