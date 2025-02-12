require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, name: "Test Product", price: 10.0) }

  describe "GET /cart" do
    before { get '/cart' }

    it "returns http success" do
      binding.pry
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

  describe "POST /cart/add_items" do
    let(:valid_params) { { product_id: product.id, quantity: 1 } }

    context "when product is not in cart" do
      it "adds product to cart" do
        expect {
          post '/cart/add_items', params: valid_params, as: :json
        }.to change(CartItem, :count).by(1)
      end

      it "returns updated cart" do
        post '/cart/add_items', params: valid_params, as: :json
        expect(JSON.parse(response.body)["products"].first).to include(
          "id" => product.id,
          "name" => "Test Product",
          "quantity" => 1,
          "unit_price" => "10.0",
          "total_price" => "10.0"
        )
      end
    end

    context 'when the product already is in the cart' do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      subject do
        post '/cart/add_items', params: valid_params, as: :json
        post '/cart/add_items', params: valid_params, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { product_id: nil, quantity: -1 } }

      it "returns error" do
        post '/cart/add_items', params: invalid_params, as: :json
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
        expect(JSON.parse(response.body)["products"]).to be_empty
      end
    end

    context "when product does not exist in cart" do
      it "returns error" do
        delete "/cart/0"
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
