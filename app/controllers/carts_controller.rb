class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: CartSerializer.new(@cart).serialize
  end

  def add_item
    service = AddCartItemService.new(@cart, cart_item_params)

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
    ActionController::Parameters.new({
      product_id: params[:product_id],
      quantity: params[:quantity]
    }).permit(:product_id, :quantity)
  end
end
