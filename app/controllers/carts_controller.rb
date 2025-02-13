class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: CartSerializer.new(@cart).serialize
  end

  def add_item
    service = AddCartItemService.new(@cart, cart_item_params.to_h)

    if service.call
      render json: CartSerializer.new(@cart.reload).serialize
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def remove_item
    service = RemoveCartItemService.new(@cart, params[:product_id])

    if service.call
      render json: CartSerializer.new(@cart.reload).serialize
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_cart
    @cart = Cart.first_or_create!
  end

  def cart_item_params
    params.reverse_merge(quantity: 1).permit(:product_id, :quantity)
  end
end
