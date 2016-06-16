# Shopify Integration

## Overview

[Shopify](http://www.shopify.com/) is a popular online store service.

This is a fully hosted and supported integration for use with the
[Wombat](http://wombat.co) product. With this integration you can perform the
following functions:

* Send product information to Shopify whenever products are created or updated.
* Send customer and order information to Shopify whenever orders are created or
updated.

## Connection Parameters

The following parameters must be setup within [Wombat](http://wombat.co):

| Name | Value |
| :----| :-----|
| shopify_apikey   | Shopify account API key (required) |
| shopify_password | Shopify account password (required) |
| shopify_host     | Shopify account host, no 'http://' (required) |
| create_shipments | Config to return corresponding shipments in order |

## Webhooks

The following webhooks are implemented. For all 'get_' webhooks, a
'shopify_id' field is return that use used to tie a Wombat object to its
corresponding Shopify object.

* **get_orders**: Retrieves a list of orders from Shopify with all details
  of line items, taxes, discounts, shipping charges etc in Wombat official
  format. Each order's 'id' will be the Shopify order ID. 'source' will be set
  to your shopify_host parameter value. Also returns a list of shipment
  objects associated with all orders.
* **get_products**: Retrieves a list of products from shopify.
  Also returns a list of inventory items, one for each product.
* **add_product**
* **update_product**
* **get_inventory**: Retrieves one inventory items for each product.
* **get_shipments**: Retrieves shipments recorded in Shopify.
* **update_shipment**
* **get_customers**: Retrieves a list of customers from Shopify (based on last
  updated timestamp).
* **add_customer**
* **update_customer**: Note that a known bug exists that makes it
  impossible to update a customer's address. We are looking into this now
  with Shopify.

## Notes

There are various differences between how Wombat and Shopify handle objects
that are worth noting and watching out for:

* Products: First, Shopify *only* stores SKU and price values in variants,
  while Wombat has a sort of base product with a SKU and a price,
  along with variants, which also have SKUs and prices. This integration
  ignores Wombat's base SKU and price and only uses those from variants.
  Second, Shopify only associates images only with base products, not for
  each variant, while Wombat associates images with the base product AND
  its variants. So, when adding a Wombat product to Shopify, we add all
  Wombat images to the Shopify base product. The 'gotcha' here is that
  products added to Shopify with images associated with variants will lose
  that association. Finally, Shopify checks if image URLs are valid prior
  to adding them, and will fail to add an image URL silently if not.
* Customers: Shopify checks to ensure that customer emails and addresses
  are unique, and will not add a customer if not.

## Wombat

[Wombat](http://wombat.co) allows you to connect to your own custom integrations.  Feel free to modify the source code and host your own version of the integration - or beter yet, help to make the official integration better by submitting a pull request!

![Wombat Logo](http://spreecommerce.com/images/wombat_logo.png)

This integration is 100% open source an licensed under the terms of the New BSD License.
