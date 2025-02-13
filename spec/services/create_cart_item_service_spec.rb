require 'rails_helper'

RSpec.describe CreateCartItemService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, name: "Test Product", price: 10.0) }
  let(:valid_params) { { product_id: product.id, quantity: 1 } }
  let(:service) { described_class.new(cart, valid_params) }

  describe '#call' do
    context 'with valid params' do
      it 'creates a new cart item' do
        expect {
          service.call
        }.to change(CartItem, :count).by(1)
      end

      it 'sets the correct quantity' do
        service.call
        cart_item = cart.cart_items.last
        expect(cart_item.quantity).to eq(1)
      end

      it 'associates the correct product' do
        service.call
        cart_item = cart.cart_items.last
        expect(cart_item.product).to eq(product)
      end

      it 'updates last interaction timestamp' do
        expect { service.call }.to change(cart, :last_interaction_at)
      end

      it 'returns true' do
        expect(service.call).to be true
      end
    end

    context 'with invalid params' do
      context 'with missing product_id' do
        let(:invalid_params) { { quantity: 1 } }
        let(:service) { described_class.new(cart, invalid_params) }

        it 'returns false' do
          expect(service.call).to be false
        end

        it 'adds error message' do
          service.call
          expect(service.errors).to include('Product ID is required')
        end

        it 'does not create cart item' do
          expect {
            service.call
          }.not_to change(CartItem, :count)
        end
      end

      context 'with invalid quantity' do
        let(:invalid_params) { { product_id: product.id, quantity: 0 } }
        let(:service) { described_class.new(cart, invalid_params) }

        it 'returns false' do
          expect(service.call).to be false
        end

        it 'adds error message' do
          service.call
          expect(service.errors).to include('Quantity must be greater than 0')
        end

        it 'does not create cart item' do
          expect {
            service.call
          }.not_to change(CartItem, :count)
        end
      end

      context 'with non-existent product' do
        let(:invalid_params) { { product_id: 999999, quantity: 1 } }
        let(:service) { described_class.new(cart, invalid_params) }

        it 'returns false' do
          expect(service.call).to be false
        end

        it 'adds error message' do
          service.call
          expect(service.errors).to include('Product not found')
        end

        it 'does not create cart item' do
          expect {
            service.call
          }.not_to change(CartItem, :count)
        end
      end

      context 'when product already exists in cart' do
        before { create(:cart_item, cart: cart, product: product, quantity: 1) }

        it 'returns false' do
          expect(service.call).to be false
        end

        it 'adds error message' do
          service.call
          expect(service.errors).to include('Product already exists in cart')
        end

        it 'does not create another cart item' do
          expect {
            service.call
          }.not_to change(CartItem, :count)
        end
      end
    end
  end
end
