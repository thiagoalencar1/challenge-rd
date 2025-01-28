class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def mark_as_abandoned
    return unless last_interaction_at < 1.hour.ago

    update(abandoned?: true)
  end

  def remove_if_abandoned
    return unless last_interaction_at < 7.days.ago

    destroy
  end

  def add_product(product, quantity)
    cart_items
      .find_or_initialize_by(product:)
      .tap { |item| item.quantity = (item.quantity || 0) + quantity }
      .tap(&:save!)
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, "Failed to save cart item: #{e.record.errors.full_messages.join(', ')}"
  end

  def remove_product(product)
    cart_items.find_by!(product:).destroy
  end
end