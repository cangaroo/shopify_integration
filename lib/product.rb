class Product

  attr_reader :shopify_id, :variants

  def add_shopify_obj shopify_product, shopify_api
    @shopify_id = shopify_product['id']
    @source = Util.shopify_host shopify_api.config
    @name = shopify_product['title']
    @description = shopify_product['body_html']

    @options = Array.new
    unless shopify_product['options'].nil?
      shopify_product['options'].each do |shopify_option|
        option = Option.new
        option.add_shopify_obj shopify_option
        @options << option
      end
    end

    @variants = Array.new
    unless shopify_product['variants'].nil?
      shopify_product['variants'].each do |shopify_variant|
        variant = Variant.new
        variant.add_shopify_obj shopify_variant, shopify_product['options']
        @variants << variant
      end
    end

    @images = Array.new
    unless shopify_product['images'].nil?
      shopify_product['images'].each do |shopify_image|
        image = Image.new
        image.add_shopify_obj shopify_image
        @images << image
      end
    end

    self
  end

  def add_wombat_obj wombat_product, shopify_api
    @shopify_id = wombat_product['shopify_id']
    @wombat_id = wombat_product['id'].to_s
    @name = wombat_product['name']
    @description = wombat_product['description']

    @options = Array.new
    unless wombat_product['options'].blank?
      wombat_product['options'].each do |wombat_option|
        option = Option.new
        option.add_wombat_obj wombat_option
        @options << option
      end
    else
      option = Option.new
      option.add_wombat_obj 'Default'
      @options << option
    end

    @variants = Array.new
    unless wombat_product['variants'].nil?
      wombat_product['variants'].each do |wombat_variant|
        variant = Variant.new
        variant.add_wombat_obj wombat_variant
        @variants << variant
      end
    end

    @images = Array.new
    unless wombat_product['images'].nil?
      wombat_product['images'].each do |wombat_image|
        image = Image.new
        image.add_wombat_obj wombat_image
        @images << image
      end
    end
    @variants.each do |variant|
      variant.images.each do |image|
        @images << image
      end
    end

    self
  end

  def wombat_obj
    {
      'id' => @shopify_id.to_s,
      'shopify_id' => @shopify_id.to_s,
      'source' => @source,
      'channel' => 'Shopify',
      'name' => @name,
      'sku' => @name,
      'description' => @description,
      'meta_description' => @description,
      'options' => Util.wombat_array(@options),
      'variants' => Util.wombat_array(@variants),
      'images' => Util.wombat_array(@images)
    }
  end

  def shopify_obj
    {
      'product'=> {
        'title'=> @name,
        'body_html'=> @description,
        'product_type' => 'None',
        'options' => Util.shopify_array(@options),
        'variants'=> Util.shopify_array(@variants).map {|v| v["variant"]},
        'images' => Util.shopify_array(@images)
      }
    }
  end

  def shopify_obj_no_variants
    obj_no_variants = shopify_obj
    obj_no_variants['product'].delete('variants')
    obj_no_variants
  end

end
