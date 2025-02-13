class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: CartSerializer.new(@cart).serialize
  end

  def create
    service = CreateCartItemService.new(@cart, cart_item_params.to_h)

    if service.call
      render json: CartSerializer.new(@cart.reload).serialize
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def update_item
    service = UpdateCartItemService.new(@cart, cart_item_params.to_h)

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
    params.permit(:product_id, :quantity)
  end
end