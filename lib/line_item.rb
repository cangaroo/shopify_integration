class LineItem

  attr_reader :sku

  def add_shopify_obj shopify_li, shopify_api
    @shopify_id = shopify_li['id']
    @shopify_parent_id = shopify_li['product_id']
    @sku = shopify_li['sku']
    @name = shopify_li['name']
    @quantity = shopify_li['quantity'].to_i
    @price = shopify_li['price'].to_f
    @requires_shipping = shopify_li['requires-shipping']
    @gift_card = shopify_li['gift-card']
    @fulfillment_status = shopify_li['fulfillment-status']

    self
  end

  def wombat_obj
    [
      {
        'product_id' => @sku,
        'shopify_id' => @shopify_id.to_s,
        'shopify_parent_id' => @shopify_parent_id.to_s,
        'name' => @name,
        'quantity' => @quantity,
        'price' => @price,
        'requires_shipping' => @requires_shipping,
        'gift_card' => @gift_card,
        'fulfillment_status' => @fulfillment_status
      }
    ]
  end

end
