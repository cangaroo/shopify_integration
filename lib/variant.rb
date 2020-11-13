class Variant

  attr_reader :shopify_id, :shopify_parent_id, :quantity, :images,
              :sku, :price, :options, :shipping_category, :name

  def add_shopify_obj shopify_variant, shopify_options
    @shopify_id = shopify_variant['id']
    @shopify_parent_id = shopify_variant['product_id']
    @name = shopify_variant['title']
    @sku = shopify_variant['sku']
    @price = shopify_variant['price'].to_f
    @shipping_category = shopify_variant['requires_shipping'] ?
                          'Shipping Required' : 'Shipping Not Required'
    @quantity = shopify_variant['inventory_quantity'].to_i

    @images = Array.new
    unless shopify_variant['images'].nil?
      shopify_variant['images'].each do |shopify_image|
        image = Image.new
        image.add_shopify_obj shopify_image
        @images << image
      end
    end

    @options = Hash.new
    shopify_variant.keys.grep(/option\d*/).each do |option_name|
      if !shopify_variant[option_name].nil?
        option_position = option_name.scan(/\d+$/).first.to_i
        real_option_name = shopify_options.select {|option| option['position'] == option_position }.first['name']
        @options[real_option_name] = shopify_variant[option_name]
      end
    end

    self
  end

  def add_wombat_obj wombat_variant
    @shopify_id = wombat_variant['shopify_id'] # or fetch it by sku?
    @price = wombat_variant['price'].to_f
    @sku = wombat_variant['sku']
    @quantity = wombat_variant['quantity'].to_i
    @options = Hash.new

    unless wombat_variant['options'].nil?
      wombat_variant['options'].values.each_with_index do |value, index|
        @options['option' + (index + 1).to_s] = value
      end
    end

    @images = Array.new
    unless wombat_variant['images'].nil?
      wombat_variant['images'].each do |wombat_image|
        image = Image.new
        image.add_wombat_obj wombat_image
        @images << image
      end
    end

    self
  end

  def shopify_obj
    {
      'variant' => {
        'price' => @price,
        'sku' => @sku,
        'inventory_management' => 'shopify'
      }.merge(@options)
    }
  end

  def wombat_obj
    {
      'sku' => @sku,
      'name'=>  @name,
      'shopify_id' => @shopify_id.to_s,
      'shopify_parent_id' => @shopify_parent_id.to_s,
      'shipping_category' => @shipping_category,
      'price' => @price,
      'quantity' => @quantity,
      'options' => @options
    }
  end

end
