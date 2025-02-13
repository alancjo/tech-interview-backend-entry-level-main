require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"

  resource :cart, only: [:show] do
    collection do
      post '/', action: :create
      patch 'add_item', action: :update_item
      delete ':product_id', action: :remove_item
    end
  end
end
