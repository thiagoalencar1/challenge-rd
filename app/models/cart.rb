class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def add_product(product, quantity)
    current_item = cart_items.find_or_initialize_by(product_id: product.id)
    current_item.quantity ||= 0
    current_item.quantity += quantity  
    current_item.cart_id = id
  
    unless current_item.save
      raise StandardError, "Failed to save cart item: #{current_item.errors.full_messages.join(', ')}"
    end
  end
end
