class CartSerializer
  def initialize(cart)
    @cart = cart
  end

  def serialize
    {
      id: @cart.id,
      products: serialize_products,
      total_price: @cart.total_price
    }
  end

  private

  def serialize_products
    @cart.cart_items.map do |item|
      {
        id: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        unit_price: item.product.price.to_s,
        total_price: (item.product.price * item.quantity).to_s
      }
    end
  end
end
