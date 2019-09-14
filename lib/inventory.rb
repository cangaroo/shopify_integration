class Inventory

  attr_reader :shopify_id, :sku, :quantity

  def add_obj variant
    @sku = variant.sku
    @shopify_id = variant.shopify_id
    @shopify_parent_id = variant.shopify_parent_id
    @quantity = variant.quantity

    self
  end

  def add_wombat_obj wombat_inventory
    @sku = wombat_inventory['product_id']
    qty=wombat_inventory['available'].to_i + wombat_inventory['received'].to_i
    @quantity = if qty<0 then 0 else qty end
    unless wombat_inventory['shopify_id'].nil?
      @shopify_id = wombat_inventory['shopify_id']
    end

    self
  end

  def wombat_obj
    {
      'id' => @sku,
      'product_id' => @sku,
      'shopify_id' => @shopify_id,
      'shopify_parent_id' => @shopify_parent_id.to_s,
      'quantity' => @quantity
    }
  end

  def shopify_obj
    {
      'inventory_quantity' => @quantity
    }
  end
end
