require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'mark_as_abandoned' do
    let(:active_cart) { create(:cart, :active) }

    it 'marks the shopping cart as abandoned if inactive for 3 hours or more' do
      expect { active_cart.mark_as_abandoned! }.to change { active_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:old_abandoned) { create(:cart, :abandoned) }

    it 'removes the shopping cart if abandoned for 7 days or more' do
      old_abandoned.update(last_interaction_at: 8.days.ago)
      expect { old_abandoned.remove_if_abandoned! }.to change { Cart.count }.by(-1)
    end
  end
end
