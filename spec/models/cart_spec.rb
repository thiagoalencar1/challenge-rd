require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  context 'when handling associations' do
    it 'has many cart items' do
      cart = create(:cart)
      cart_item = create(:cart_item, cart: cart)

      expect(cart.cart_items).to include(cart_item)
    end

    it 'destroys associated cart items when deleted' do
      cart = create(:cart)
      cart_item = create(:cart_item, cart: cart)

      expect { cart.destroy }.to change(CartItem, :count).by(-1)
    end
  end
end
