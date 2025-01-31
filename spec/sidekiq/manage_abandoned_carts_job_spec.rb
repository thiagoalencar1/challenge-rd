require 'rails_helper'

RSpec.describe ManageAbandonedCartsJob, type: :job do
  let!(:recent_cart) { create(:cart, updated_at: 1.hour.ago) }
  let!(:abandoned_cart) { create(:cart, updated_at: 4.hours.ago) }
  let!(:old_abandoned_cart) { create(:cart, abandoned_at: 8.days.ago) }

  describe '#perform' do
    it 'does not delete recent carts' do
      expect { subject.perform }.not_to change { recent_cart.reload.abandoned_at }
    end

    it 'marks carts as abandoned' do
      expect { subject.perform }
        .to change { abandoned_cart.reload.abandoned_at }
        .from(nil)
        .to(be_present)
    end

    it 'deletes old abandoned carts' do
      expect { subject.perform }.to change { Cart.count }.by(-1)
    end
  end
end
