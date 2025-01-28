require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }

  describe 'associations' do
    it 'belongs to a cart' do
      cart_item = CartItem.new(cart: cart, product: product, quantity: 1)
      expect(cart_item.cart).to eq(cart)
    end

    it 'belongs to a product' do
      cart_item = CartItem.new(cart: cart, product: product, quantity: 1)
      expect(cart_item.product).to eq(product)
    end
  end

  describe 'validations' do
    it 'requires quantity to be present' do
      cart_item = CartItem.new(cart: cart, product: product)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include("can't be blank")
    end

    it 'requires quantity to be greater than 0' do
      cart_item = CartItem.new(cart: cart, product: product, quantity: 0)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end
  end
end
