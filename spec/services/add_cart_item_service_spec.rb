require 'rails_helper'

RSpec.describe AddCartItemService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, quantity: 5) }
  let(:valid_params) { { product_id: product.id, quantity: 1 } }
  let(:service) { described_class.new(cart, valid_params) }

  describe '#call' do
    context 'with valid params' do
      it 'adds item to cart' do
        expect { service.call }.to change(CartItem, :count).by(1)
      end

      it 'updates last interaction timestamp' do
        expect { service.call }.to change(cart, :last_interaction_at)
      end

      context 'when product already exists in cart' do
        let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

        it 'updates the quantity' do
          expect { service.call }.to change { cart_item.reload.quantity }.by(1)
        end
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
      end

      context 'with insufficient stock' do
        let(:invalid_params) { { product_id: product.id, quantity: 10 } }
        let(:service) { described_class.new(cart, invalid_params) }

        it 'returns false' do
          expect(service.call).to be false
        end

        it 'adds error message' do
          service.call
          expect(service.errors).to include('Product is out of stock')
        end
      end
    end
  end
end