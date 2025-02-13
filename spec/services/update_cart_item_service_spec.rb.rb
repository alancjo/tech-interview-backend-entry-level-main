require 'rails_helper'

RSpec.describe UpdateCartItemService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }
  let(:valid_params) { { product_id: product.id, quantity: 2 } }
  let(:service) { described_class.new(cart, valid_params) }

  describe '#call' do
    context 'with valid params' do
      before { cart_item }

      it 'increments item quantity' do
        expect {
          service.call
        }.to change { cart_item.reload.quantity }.from(1).to(3)
      end

      it 'updates last interaction timestamp' do
        expect { service.call }.to change(cart, :last_interaction_at)
      end

      it 'returns true' do
        expect(service.call).to be true
      end

      it 'accumulates quantities across multiple calls' do
        2.times { service.call }
        expect(cart_item.reload.quantity).to eq(5)
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

        before { cart_item }

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

      context 'with product not in cart' do
        let(:other_product) { create(:product) }
        let(:invalid_params) { { product_id: other_product.id, quantity: 1 } }
        let(:service) { described_class.new(cart, invalid_params) }

        before { cart_item }

        it 'returns false' do
          expect(service.call).to be false
        end

        it 'adds error message' do
          service.call
          expect(service.errors).to include('Product not found in cart')
        end
      end
    end
  end
end