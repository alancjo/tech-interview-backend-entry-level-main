class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :status, presence: true

  enum status: { active: 0, abandoned: 1 }

  def total_price
    cart_items.sum(&:total_price)
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
  def mark_as_abandoned!
    update!(status: :abandoned)
  end
end
