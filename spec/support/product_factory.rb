module Factories
  def self.product
    {
      "id" => 1,
      "name" => "Ruby on Rails Tote",
      "description" => "Distinctio nostrum repellat sit possimus dicta totam cum et. Dolore et illum omnis cum. Quo unde quia magnam natus ea eligendi error suscipit. Sit eligendi porro et explicabo qui aut provident.",
      "price" => "15.99",
      "display_price" => "$15.99",
      "available_on" => "2016-06-02T14:04:07.705Z",
      "slug" => "ruby-on-rails-tote",
      "meta_description" => nil,
      "meta_keywords" => nil,
      "shipping_category_id" => 1,
      "taxon_ids" => [3,12],
      "total_on_hand" => 8,
      "master" => {
        "id" => 1,
        "name" => "Ruby on Rails Tote",
        "sku" => "ROR-00011",
        "price" => "15.99",
        "weight" => "0.0",
        "height" => nil,
        "width" => nil,
        "depth" => nil,
        "is_master" => true,
        "slug" => "ruby-on-rails-tote",
        "description" => "Distinctio nostrum repellat sit possimus dicta totam cum et. Dolore et illum omnis cum. Quo unde quia magnam natus ea eligendi error suscipit. Sit eligendi porro et explicabo qui aut provident.",
        "track_inventory" => true,
        "cost_price" => "17.0",
        "option_values" => [],
        "images" => [
          {
            "id" => 21,
            "position" => 1,
            "attachment_content_type" => "image/jpeg",
            "attachment_file_name" => "ror_tote.jpeg",
            "type" => "Spree::Image",
            "attachment_updated_at" => "2016-06-02T14:04:18.309Z",
            "attachment_width" => 360,
            "attachment_height" => 360,
            "alt" => nil,
            "viewable_type" => "Spree::Variant",
            "viewable_id" => 1,
            "mini_url" => "/spree/products/21/mini/ror_tote.jpeg?1464876258",
            "small_url" => "/spree/products/21/small/ror_tote.jpeg?1464876258",
            "product_url" => "/spree/products/21/product/ror_tote.jpeg?1464876258",
            "large_url" => "/spree/products/21/large/ror_tote.jpeg?1464876258"
          },
          {
            "id" => 22,
            "position" => 2,
            "attachment_content_type" => "image/jpeg",
            "attachment_file_name" => "ror_tote_back.jpeg",
            "type" => "Spree::Image",
            "attachment_updated_at" => "2016-06-02T14:04:18.638Z",
            "attachment_width" => 360,
            "attachment_height" => 360,
            "alt" => nil,
            "viewable_type" => "Spree::Variant",
            "viewable_id" => 1,
            "mini_url" => "/spree/products/22/mini/ror_tote_back.jpeg?1464876258",
            "small_url" => "/spree/products/22/small/ror_tote_back.jpeg?1464876258",
            "product_url" => "/spree/products/22/product/ror_tote_back.jpeg?1464876258",
            "large_url" => "/spree/products/22/large/ror_tote_back.jpeg?1464876258"
          }
        ],
        "display_price" => "$15.99",
        "options_text" => "",
        "in_stock" => true,
        "is_backorderable" => true,
        "total_on_hand" => 8,
        "is_destroyed" => false
      },
      "variants" => [],
      "option_types" => [],
      "product_properties" => [
        {
          "id" => 25,
          "product_id" => 1,
          "property_id" => 9,
          "value" => "Tote",
          "property_name" => "Type"
        },
        {
          "id" => 26,
          "product_id" => 1,
          "property_id" => 10,
          "value" => "15\" x 18\" x 6\"",
          "property_name" => "Size"
        },
        {
          "id" => 27,
          "product_id" => 1,
          "property_id" => 11,
          "value" => "Canvas",
          "property_name" => "Material"
        }
      ],
      "classifications" => [
        {
          "taxon_id" => 3,
          "position" => 1,
          "taxon" => {
            "id" => 3,
            "name" => "Bags",
            "pretty_name" => "Categories -\u003e Bags",
            "permalink" => "categories/bags",
            "parent_id" => 1,
            "taxonomy_id" => nil,
            "taxons" => []
          }
        },
        {
          "taxon_id" => 12,
          "position" => 1,
          "taxon" => {
            "id" => 12,
            "name" => "Rails",
            "pretty_name" => "Brands -\u003e Rails",
            "permalink" => "brands/rails",
            "parent_id" => 8,
            "taxonomy_id" => nil,
            "taxons" => []
          }
        }
      ],
      "has_variants" => false
    }
  end
end