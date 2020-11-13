class Util

  def self.wombat_array objs
    wombat_array = Array.new
    objs.each do |obj|
      wombat_obj = obj.wombat_obj
      if wombat_obj.kind_of?(Array)
        wombat_array += obj.wombat_obj
      else
        wombat_array << obj.wombat_obj
      end
    end
    wombat_array
  end

  def self.shopify_array objs
    shopify_array = Array.new
    objs.each do |obj|
      shopify_array << obj.shopify_obj
    end
    shopify_array
  end

  def self.wombat_shipment_status shopify_status
    (shopify_status == 'success') ? 'shipped' : 'ready'
  end

  def self.shopify_shipment_status wombat_status
    shopify_status = 'error'

    case wombat_status
    when 'shipped'
      shopify_status = 'success'
    when 'ready'
      shopify_status = 'pending'
    else
      shopify_status = 'failure'
    end

    shopify_status
  end

  def self.shopify_apikey wombat_config
    wombat_config['shopify_apikey']
  end

  def self.shopify_password wombat_config
    wombat_config['shopify_password']
  end

  def self.shopify_host wombat_config
    wombat_config['shopify_host']
  end

  def self.shopify_version wombat_config
    wombat_config['shopify_version']
  end

end
