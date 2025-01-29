class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  before_save :set_last_interaction_time

  def mark_as_abandoned
    update(abandoned_at: Time.current)
  end

  def remove_if_abandoned
    destroy if abandoned_at && abandoned_at >= 7.days.ago
  end
  def add_product(product, quantity)
    transaction do
      item = cart_items.find_or_initialize_by(product: product)
      item.quantity = (item.quantity || 0) + quantity
      item.save!
      update_total_price!
      save!
      item
    end
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, "Failed to save cart item: #{e.record.errors.full_messages.join(', ')}"
  end

  def remove_product(product)
    cart_items.find_by!(product:).destroy
  end

  private

  def update_total_price!
    self.total_price = cart_items.sum { |item| item.quantity * item.product.price }
  end

  def set_last_interaction_time
    self.last_interaction_at = Time.current
  end
end
