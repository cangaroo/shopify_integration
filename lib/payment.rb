class Payment
  attr_reader :transaction, :order

  delegate :amount, to: :transaction

  def add_shopify_obj(shopify_transaction, shopify_api, shopify_order)
    @transaction = shopify_transaction
    @order = shopify_order
    self
  end

  def wombat_obj
    order['payment_details'].slice('credit_card_number', 'credit_card_company').merge(
      'status' => 'completed',
      'amount' => amount.to_f,
      'payment_method' => payment_method
    )
  end

  private

  def payment_method
    transaction.gateway
  end

end
