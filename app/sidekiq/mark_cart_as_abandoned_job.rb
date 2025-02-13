class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.process_abandoned_carts
  end
end
