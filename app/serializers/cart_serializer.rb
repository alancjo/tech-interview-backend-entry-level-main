class CartSerializer
  def initialize(cart)
    @cart = cart
  end

  def serialize
    {
      id: @cart.id,
      products: serialize_products,
      total_price: calculate_total_price
    }
  end

  private

  def serialize_products
    @cart.cart_items.includes(:product).map do |item|
      {
        id: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        unit_price: item.product.price,
        total_price: calculate_item_total(item)
      }
    end
  end

  def calculate_item_total(item)
    item.quantity * item.product.price
  end

  def calculate_total_price
    @cart.cart_items.sum { |item| calculate_item_total(item) }
  end
end