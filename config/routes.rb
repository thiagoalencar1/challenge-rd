require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check
  
  resources :carts, only: [:create, :show, :destroy] do
    resources :cart_items, only: [:create, :index]
  end

  resources :products, only: [:index, :show]

  root "rails/health#show"
end
