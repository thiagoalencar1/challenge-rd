# frozen_string_literal: true

class ManageAbandonedCartsJob
 include Sidekiq::Job

  def perform
    delete_old_abandoned_carts
    mark_abandoned_carts
  end
  
  private

  def mark_abandoned_carts
    Cart.where('updated_at < ?', 3.hours.ago).where(abandoned_at: nil).each do |cart|
      cart.update!(abandoned_at: Time.current)
      Rails.logger.info "Cart ##{cart.id} marked as abandoned"
    end
  end

  def delete_old_abandoned_carts
    Cart.where('abandoned_at < ?', 7.days.ago).each do |cart|
      cart.destroy!
      Rails.logger.info "Cart ##{cart.id} deleted (abandoned for more than 7 days)"
    end
  end
end
