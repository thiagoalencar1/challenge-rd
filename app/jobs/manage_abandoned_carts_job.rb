# frozen_string_literal: true

require 'sidekiq-scheduler'

class ManageAbandonedCartsJob
  include Sidekiq::Worker
  MARK_AS_ABANDONED_TIMEOUT = 3.hours.ago
  DELETE_OLD_ABANDONED_CARTS_TIMEOUT = 7.days.ago

  def perform
    mark_abandoned_carts
    delete_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    Cart.where('last_interaction_at > ?', MARK_AS_ABANDONED_TIMEOUT).find_each do |cart|
      cart.mark_as_abandoned
      Rails.logger.info "Cart ##{cart.id} marked as abandoned"
    end
  end

  def delete_old_abandoned_carts
    Cart.where('abandoned_at > ?', DELETE_OLD_ABANDONED_CARTS_TIMEOUT).find_each do |cart|
      cart.remove_if_abandoned
      Rails.logger.info "Cart ##{cart.id} deleted (abandoned for more than 7 days)"
    end
  end
end
