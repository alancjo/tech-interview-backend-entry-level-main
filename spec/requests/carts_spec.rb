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
    context "when cart exists with products" do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

      before do
        get '/cart', headers: { 'ACCEPT' => 'application/json' }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns cart with products" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to include(
          "id" => cart.id,
          "total_price" => "20.0"
        )
        expect(parsed_response["products"].first).to include(
          "id" => product.id,
          "name" => "Test Product",
          "quantity" => 2,
          "unit_price" => "10.0",
          "total_price" => "20.0"
        )
      end
    end

    context "when cart doesn't exist" do
      it "creates a new cart" do
        expect {
          get '/cart', headers: { 'ACCEPT' => 'application/json' }
        }.to change(Cart, :count).by(1)
      end
    end
  end

  describe "POST /cart" do
    let(:valid_params) { { product_id: product.id, quantity: 1 } }

    context "when product is not in cart" do
      before { cart }

      it "adds product to cart" do
        expect {
          post '/cart', params: valid_params, as: :json
        }.to change(CartItem, :count).by(1)
      end

      it "returns updated cart" do
        post '/cart', params: valid_params, as: :json
        expect(response).to have_http_status(:success)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["products"].first).to include(
          "id" => product.id,
          "name" => "Test Product",
          "quantity" => 1,
          "unit_price" => "10.0",
          "total_price" => "10.0"
        )
      end
    end

    context "when product already exists in cart" do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      it "increases the quantity" do
        expect {
          post '/cart', params: valid_params, as: :json
        }.not_to change(CartItem, :count)
        expect(cart_item.reload.quantity).to eq(2)
      end
    end

    context "with invalid params" do
      context "when product_id is missing" do
        let(:invalid_params) { { quantity: 1 } }

        it "returns unprocessable entity status" do
          post '/cart', params: invalid_params, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to include("Product ID is required")
        end
      end

      context "when quantity is invalid" do
        let(:invalid_params) { { product_id: product.id, quantity: 0 } }

        it "returns unprocessable entity status" do
          post '/cart', params: invalid_params, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to include("Quantity must be greater than 0")
        end
      end

      context "when product doesn't exist" do
        let(:invalid_params) { { product_id: 0, quantity: 1 } }

        it "returns unprocessable entity status" do
          post '/cart', params: invalid_params, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to include("Product not found")
        end
      end
    end
  end

  describe "PATCH /cart/add_item" do
    let(:valid_params) { { product_id: product.id, quantity: 1 } }

    context "when product exists in cart" do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      it "updates item quantity" do
        patch '/cart/add_item', params: valid_params, as: :json
        expect(cart_item.reload.quantity).to eq(2)
      end

      it "returns updated cart" do
        patch '/cart/add_item', params: valid_params, as: :json
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["products"].first).to include(
          "quantity" => 2,
          "total_price" => "20.0"
        )
      end
    end

    context "when product doesn't exist in cart" do
      it "adds the product to cart" do
        expect {
          patch '/cart/add_item', params: valid_params, as: :json
        }.to change(CartItem, :count).by(1)
      end
    end

    context "with invalid params" do
      it "returns error for negative quantity" do
        patch '/cart/add_item', params: { product_id: product.id, quantity: -1 }, as: :json
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

    context "when product doesn't exist in cart" do
      it "returns error" do
        delete "/cart/0"
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to include("Product not found in cart")
      end
    end

    context "when cart becomes empty" do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product) }

      it "returns empty products array" do
        delete "/cart/#{product.id}"
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["products"]).to be_empty
        expect(parsed_response["total_price"]).to eq(0.0)
      end
    end
  end
end
