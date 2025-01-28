require 'rails_helper'

RSpec.describe ManageAbandonedCartsJob, type: :job do
  let(:active_cart_old) { create(:cart, updated_at: 4.hours.ago) }
  let(:active_cart_recent) { create(:cart, updated_at: 1.hour.ago) }
  let(:abandoned_cart_old) { create(:cart, :abandoned, abandoned_at: 8.days.ago) }
  let(:abandoned_cart_recent) { create(:cart, :abandoned, abandoned_at: 5.days.ago) }

  describe '#perform' do
    it 'marks active carts as abandoned if inactive for more than 3 hours' do
      expect { described_class.new.perform }
        .to change { active_cart_old.reload.active }.from(true).to(false)
        .and(not_change { active_cart_recent.reload.active })
    end

    it 'sets abandoned_at for carts marked as abandoned' do
      described_class.new.perform
      expect(active_cart_old.reload.abandoned_at).to be_present
    end

    it 'removes carts that have been abandoned for more than 7 days' do
      expect { described_class.new.perform }
        .to change { Cart.exists?(abandoned_cart_old.id) }.from(true).to(false)
    end

    it 'does not remove carts abandoned for less than 7 days' do
      expect { described_class.new.perform }
        .not_to(change { Cart.exists?(abandoned_cart_recent.id) })
    end
  end
end