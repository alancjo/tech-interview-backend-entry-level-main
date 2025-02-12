class MarkCartAsAbandonedJob
  include Sidekiq::Job

  # TODO Impletemente um Job para gerenciar, marcar como abandonado. E remover carrinhos sem interação.
  def perform
    mark_abandoned_carts
    remove_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    Cart.active
       .where('last_interaction_at < ?', 3.hours.ago)
       .find_each(&:mark_as_abandoned!)
  end

  def remove_old_abandoned_carts
    Cart.abandoned
       .where('last_interaction_at < ?', 7.days.ago)
       .destroy_all
  end
end