require 'rails_helper'

RSpec.describe "/carts", type: :request do
  before do
    CartItem.destroy_all
    Cart.destroy_all
    Product.destroy_all
  end

  let(:cart) { create(:cart) }
  let(:product) { create(:product, name: "Test Product", price: 10.0) }

  describe "GET /cart" do
    before do
      get '/cart', headers: { 'ACCEPT' => 'application/json' }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns cart with products" do
      expect(JSON.parse(response.body)).to include(
        "id",
        "products",
        "total_price"
      )
    end
  end

  describe "POST /cart/add_item" do
    let(:valid_params) { { product_id: product.id, quantity: 1 } }

    context "when product is not in cart" do
      before do
        cart # ensure cart exists
        product # ensure product exists
      end

      it "adds product to cart" do
        expect {
          post '/cart/add_item', params: valid_params, as: :json
        }.to change(CartItem, :count).by(1)
      end

      it "returns updated cart" do
        post '/cart/add_item', params: valid_params, as: :json
        parsed_response = JSON.parse(response.body)

        expect(parsed_response["products"].first).to match(
          "id" => product.id,
          "name" => product.name,
          "quantity" => 1,
          "unit_price" => "10.0",
          "total_price" => "10.0"
        )
      end
    end

    context 'when the product already is in the cart' do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      it 'updates the quantity of the existing item in the cart' do
        initial_quantity = cart_item.quantity

        2.times do
          post '/cart/add_item', params: valid_params, as: :json
        end

        expect(cart_item.reload.quantity).to eq(initial_quantity + 2)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { product_id: nil } } # Removed quantity to trigger validation

      before { cart }

      it "returns error" do
        post '/cart/add_item', params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:cart_item) { create(:cart_item, cart: cart, product: product) }

    context "when product exists in cart" do
      it "removes product from cart" do
        expect {
          delete "/cart/#{product.id}"
        }.to change(CartItem, :count).by(-1)
      end

      it "returns updated cart" do
        delete "/cart/#{product.id}"
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["products"]).to eq([])
      end
    end
  end
end
