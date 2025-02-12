class RemoveCartItemService
  attr_reader :cart, :product_id, :errors

  def initialize(cart, product_id)
    @cart = cart
    @product_id = product_id
    @errors = []
  end

  def call
    return false unless valid?

    ActiveRecord::Base.transaction do
      remove_item
      update_cart_interaction
    end

    true
  rescue ActiveRecord::RecordNotFound => e
    @errors << 'Product not found in cart'
    false
  rescue ActiveRecord::RecordInvalid => e
    @errors << e.message
    false
  end

  private

  def valid?
    return add_error('Product ID is required') if product_id.blank?
    return add_error('Product not found in cart') unless cart_item

    true
  end

  def cart_item
    @cart_item ||= cart.cart_items.find_by(product_id: product_id)
  end

  def remove_item
    cart_item.destroy!
  end

  def update_cart_interaction
    cart.touch(:last_interaction_at)
  end

  def add_error(message)
    @errors << message
    false
  end
end
