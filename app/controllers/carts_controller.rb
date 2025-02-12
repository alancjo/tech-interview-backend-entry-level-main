module Api
  module V1
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
        @cart = Cart.find_or_create_by!(session_id: session.id)
      end

      def cart_item_params
        params.require(:cart_item).permit(:product_id, :quantity)
      end
    end
  end
end