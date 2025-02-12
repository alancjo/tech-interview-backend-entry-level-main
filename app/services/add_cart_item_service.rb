class AddCartItemService
  attr_reader :cart, :params, :errors

  def initialize(cart, params)
    @cart = cart
    @params = params
    @errors = []
  end

  def call
    return false unless valid?

    ActiveRecord::Base.transaction do
      add_or_update_item
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

    true
  end

  def invalid_quantity?
    params[:quantity].to_i <= 0
  end

  def product
    @product ||= Product.find_by(id: params[:product_id])
  end

  def add_or_update_item
    cart_item = cart.cart_items.find_or_initialize_by(product_id: params[:product_id])

    if cart_item.new_record?
      cart_item.quantity = params[:quantity]
    else
      cart_item.quantity += params[:quantity].to_i
    end

    cart_item.save!
  end

  def update_cart_interaction
    cart.touch(:last_interaction_at)
  end

  def add_error(message)
    @errors << message
    false
  end
end
