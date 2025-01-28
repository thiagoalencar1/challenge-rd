require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'when validating' do
    it 'validates presence of name' do
      product = described_class.new(price: 100)
      expect(product.valid?).to be_falsey
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'validates presence of price' do
      product = described_class.new(name: 'name')
      expect(product.valid?).to be_falsey
      expect(product.errors[:price]).to include("can't be blank")
    end

    it 'validates numericality of price' do
      product = described_class.new(price: -1)
      expect(product.valid?).to be_falsey
      expect(product.errors[:price]).to include("must be greater than or equal to 0")
    end
  end

  context 'when handling associations' do
    it 'has many cart items' do
      product = create(:product)
      cart = create(:cart)
      cart_item = create(:cart_item, product: product, cart: cart)

      expect(product.cart_items).to include(cart_item)
    end

    it 'destroys associated cart items when deleted' do
      product = create(:product)
      cart = create(:cart)
      create(:cart_item, product: product, cart: cart)

      expect { product.destroy }.to change(CartItem, :count).by(-1)
    end
  end
end
