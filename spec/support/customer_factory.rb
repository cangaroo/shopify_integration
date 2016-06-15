module Factories
  def self.customer
    {
      "id" => 1,
      "email" => "spree@example.com",
      "created_at" => "2016-06-02T14:04:00.320Z",
      "updated_at" => "2016-06-02T14:19:53.439Z",
      "bill_address" => {
        "id" => 4,
        "firstname" => "Spree",
        "lastname" => "User",
        "full_name" => "Spree User",
        "address1" => "1 street",
        "address2" => "",
        "city" => "new york",
        "zipcode" => "10007",
        "phone" => "1234567890",
        "company" => nil,
        "alternative_phone" => nil,
        "country_id" => 232,
        "state_id" => 3561,
        "state_name" => nil,
        "state_text" => "NY",
        "country" => {
          "id" => 232,
          "iso_name" => "UNITED STATES",
          "iso" => "US",
          "iso3" => "USA",
          "name" => "United States",
          "numcode" => 840
        },
        "state" => {
          "id" => 3561,
          "name" => "New York",
          "abbr" => "NY",
          "country_id" => 232
        }
      },
      "ship_address" => {
        "id" => 3,
        "firstname" => "Spree",
        "lastname" => "User",
        "full_name" => "Spree User",
        "address1" => "1 street",
        "address2" => "",
        "city" => "new york",
        "zipcode" => "10007",
        "phone" => "1234567890",
        "company" => nil,
        "alternative_phone" => nil,
        "country_id" => 232,
        "state_id" => 3561,
        "state_name" => nil,
        "state_text" => "NY",
        "country" => {
          "id" => 232,
          "iso_name" => "UNITED STATES",
          "iso" => "US",
          "iso3" => "USA",
          "name" => "United States",
          "numcode" => 840
        },
        "state" => {
          "id" => 3561,
          "name" => "New York",
          "abbr" => "NY",
          "country_id" => 232
        }
      }
    }
  end
end