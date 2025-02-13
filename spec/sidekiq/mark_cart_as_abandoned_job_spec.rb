require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  before do
    CartItem.destroy_all
    Cart.destroy_all
    Product.destroy_all
  end

  describe '#perform', freeze_time: true do
    let!(:active_cart) { create(:cart, status: :active, last_interaction_at: Time.current) }
    let!(:inactive_cart) { create(:cart, status: :active, last_interaction_at: 4.hours.ago) }
    let!(:abandoned_cart) do
      create(:cart,
        status: :abandoned,
        last_interaction_at: 8.days.ago,
        updated_at: 8.days.ago
      )
    end

    it 'marks carts as abandoned after 3 hours of inactivity' do
      inactive_cart.update(last_interaction_at: 4.hours.ago)

      expect {
        described_class.new.perform
      }.to change { inactive_cart.reload.status }.from('active').to('abandoned')
    end

    it 'does not mark active carts as abandoned' do
      expect {
        described_class.new.perform
      }.not_to change { active_cart.reload.status }
    end

    it 'removes carts that have been abandoned for more than 7 days' do
      expect {
        described_class.new.perform
      }.to change(Cart, :count).by(-1)
    end
  end
end
