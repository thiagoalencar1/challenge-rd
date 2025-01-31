require 'rails_helper'

RSpec.describe "/cart", type: :request do
  def json_response = JSON.parse(response.body)
  let(:product) { create(:product) }

  describe "POST /cart" do
    context "when adding products" do
      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it "creates a new cart with the product" do
        expect { subject }.to change(Cart, :count).by(1)
        expect(response).to have_http_status(:created)

        expect(json_response["cart_items"].first["quantity"]).to eq(1)
        expect(json_response["total_price"]).to eq("10.0")
      end

      it "reuses the cart from session" do
        subject
        first_cart_id = json_response["id"]

        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
        second_cart_id = json_response["id"]

        expect(second_cart_id).to eq(first_cart_id)
      end

      it "accumulates quantity for same product" do
        subject
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json

        expect(json_response["cart_items"].first["quantity"]).to eq(2)
        expect(json_response["total_price"]).to eq("20.0")
      end
    end

    context "with invalid parameters" do
      it "returns error for non-existent product" do
        post '/cart', params: { product_id: 999, quantity: 1 }, as: :json
        
        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("Produto não encontrado")
      end

      it "returns error for invalid quantity" do
        post '/cart', params: { product_id: product.id, quantity: 0 }, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to eq("A quantidade do produto deve ser maior que zero")
      end
    end
  end

  describe "GET /cart" do
    let!(:cart) { create(:cart, :with_items) }

    before do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
    end

    it "returns the cart with its items" do
      get "/cart", as: :json
      
      expect(response).to have_http_status(:ok)

      expect(json_response["cart_items"]).to be_present
      expect(json_response["total_price"]).to be_present
    end
  end

  describe "POST /cart/add_item" do
    let!(:cart) { create(:cart, :with_items) }

    before do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
    end

    it "adds item to the cart" do
      post "/cart/add_item", params: { product_id: product.id, quantity: 2 }, as: :json
      
      expect(response).to have_http_status(:ok)
      expect(json_response["cart_items"].find { |p| p["id"] == product.id }["quantity"]).to eq(3)
    end

    it "returns error for non-existent product" do
      post "/cart/add_item", params: { product_id: 999, quantity: 1 }, as: :json
      
      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to eq("Produto não encontrado")
    end
  end

  describe "POST /cart/:product_id" do
    let!(:cart) { create(:cart) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

    before do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
    end

    it "removes the product from cart" do
      post "/cart/#{product.id}", as: :json
      
      expect(response).to have_http_status(:ok)
      expect(json_response["cart_items"]).to be_empty
    end

    it "returns error for non-existent product" do
      post "/cart/999", as: :json
      
      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to eq("Produto não encontrado")
    end
  end
end
