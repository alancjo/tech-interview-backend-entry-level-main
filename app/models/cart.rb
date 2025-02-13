class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :status, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  enum status: { active: 0, abandoned: 1 }

  before_create :set_last_interaction_at
  after_update :update_last_interaction_at, if: :saved_change_to_status?

  scope :inactive, -> {
    where(status: :active)
      .where('last_interaction_at < ?', 3.hours.ago)
  }

  scope :removable, -> {
    where(status: :abandoned)
      .where('updated_at < ?', 7.days.ago)
  }

  def total_price
    cart_items.sum(&:total_price)
  end

  def self.process_abandoned_carts
    mark_inactive_as_abandoned
    remove_old_abandoned
  end

  def self.mark_inactive_as_abandoned
    inactive.find_each(&:mark_as_abandoned!)
  end

  def self.remove_old_abandoned
    removable.destroy_all
  end

  def mark_as_abandoned!
    update!(status: :abandoned)
  end

  private

  def update_last_interaction_at
    touch(:last_interaction_at)
  end

  def set_last_interaction_at
    self.last_interaction_at = Time.current
  end
end
