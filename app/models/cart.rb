class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :status, presence: true

  enum status: { active: 0, abandoned: 1 }

  before_create :set_last_interaction_at

  def total_price
    cart_items.sum(&:total_price)
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
  def mark_as_abandoned!
    update!(status: :abandoned)
  end

  private

  def set_last_interaction_at
    self.last_interaction_at = Time.current
  end
end
