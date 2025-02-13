class UpdateCartItemService
  attr_reader :cart, :params, :errors

  def initialize(cart, params)
    @cart = cart
    @params = params
    @errors = []
  end

  def call
    return false unless valid?

    ActiveRecord::Base.transaction do
      update_item
      update_cart_interaction
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    @errors << e.message
    false
  end

  private

  def valid?
    return add_error('Product ID is required') if params[:product_id].blank?
    return add_error('Quantity must be greater than 0') if invalid_quantity?
    return add_error('Product not found') unless product
    return add_error('Product not found in cart') unless cart_item

    true
  end

  def invalid_quantity?
    params[:quantity].to_i <= 0
  end

  def product
    @product ||= Product.find_by(id: params[:product_id])
  end

  def cart_item
    @cart_item ||= cart.cart_items.find_by(product_id: params[:product_id])
  end

  def update_item
    new_quantity = cart_item.quantity + params[:quantity].to_i
    cart_item.update!(quantity: new_quantity)
  end

  def update_cart_interaction
    cart.touch(:last_interaction_at)
  end

  def add_error(message)
    @errors << message
    false
  end
end