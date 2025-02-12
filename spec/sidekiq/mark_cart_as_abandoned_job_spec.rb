require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do

  describe '#perform' do
    let!(:active_cart) { create(:cart, last_interaction_at: Time.current) }
    let!(:inactive_cart) { create(:cart, last_interaction_at: 4.hours.ago) }
    let!(:abandoned_cart) { create(:cart, :abandoned, last_interaction_at: 8.days.ago) }

    it 'marks carts as abandoned after 3 hours of inactivity' do
      expect {
        described_class.perform_now
      }.to change { inactive_cart.reload.status }.from('active').to('abandoned')
    end

    it 'does not mark active carts as abandoned' do
      expect {
        described_class.perform_now
      }.not_to change { active_cart.reload.status }
    end

    it 'removes carts that have been abandoned for more than 7 days' do
      expect {
        described_class.perform_now
      }.to change(Cart, :count).by(-1)
    end
  end

end
