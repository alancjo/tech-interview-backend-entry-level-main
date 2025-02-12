require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"

  resource :cart, only: [:show] do
    post 'add_item', on: :collection
    delete ':product_id', to: 'carts#remove_item', on: :collection
  end
end
