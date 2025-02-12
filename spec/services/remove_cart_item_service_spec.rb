require 'rails_helper'

RSpec.describe RemoveCartItemService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product) }
  let(:service) { described_class.new(cart, product.id) }

  describe '#call' do
    context 'with valid params' do
      it 'removes item from cart' do
        expect { service.call }.to change(CartItem, :count).by(-1)
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
        let(:service) { described_class.new(cart, nil) }

        it 'returns false' do
          expect(service.call).to be false
        end

        it 'adds error message' do
          service.call
          expect(service.errors).to include('Product ID is required')
        end
      end

      context 'with non-existent product in cart' do
        let(:service) { described_class.new(cart, 999999) }

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