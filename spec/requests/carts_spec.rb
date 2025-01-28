require 'rails_helper'

RSpec.describe "/carts", type: :request do
  def json_response = JSON.parse(response.body)
  let(:product) { create(:product) }

  describe "POST /carts" do
    context "when adding products" do
      subject do
        post '/carts', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it "creates a new cart with the product" do
        expect { subject }.to change(Cart, :count).by(1)
        expect(response).to have_http_status(:created)
        
        expect(json_response["products"].first["quantity"]).to eq(1)
        expect(json_response["total_price"]).to eq("10.0")
      end

      it "reuses the cart from session" do
        subject
        first_cart_id = json_response["id"]

        post '/carts', params: { product_id: product.id, quantity: 1 }, as: :json
        second_cart_id = json_response["id"]

        expect(second_cart_id).to eq(first_cart_id)
      end

      it "accumulates quantity for same product" do
        subject
        post '/carts', params: { product_id: product.id, quantity: 1 }, as: :json

        expect(json_response["products"].first["quantity"]).to eq(2)
        expect(json_response["total_price"]).to eq("20.0")
      end
    end

    context "with invalid parameters" do
      it "returns error for non-existent product" do
        post '/carts', params: { product_id: 999, quantity: 1 }, as: :json
        
        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("Produto não encontrado")
      end

      it "returns error for invalid quantity" do
        post '/carts', params: { product_id: product.id, quantity: 0 }, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to eq("A quantidade do produto deve ser maior que zero")
      end
    end
  end

  describe "GET /carts/:id" do
    let(:cart) { create(:cart, :with_items) }

    it "returns the cart with its items" do
      get "/carts/#{cart.id}", as: :json
      
      expect(response).to have_http_status(:ok)
      expect(json_response["products"]).to be_present
      expect(json_response["total_price"]).to eq((cart.cart_items.sum { |item| item.quantity * item.product.price }).to_s)
    end

    it "returns not found for non-existent cart" do
      get "/carts/999", as: :json
      
      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to eq("Carrinho não encontrado")
    end
  end

  describe "DELETE /carts/:id" do
    let!(:cart) { create(:cart, :with_items) }

    it "destroys the requested cart" do
      expect { delete "/carts/#{cart.id}", as: :json}.to change(Cart, :count).by(-1)
      
      expect(response).to have_http_status(:no_content)
    end

    it "returns not found for non-existent cart" do
      delete "/carts/999", as: :json
      
      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to eq("Carrinho não encontrado")
    end
  end
end
