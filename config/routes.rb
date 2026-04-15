Rails.application.routes.draw do
  devise_for :members
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Kiosk - no login
  namespace :kiosk do
    root "drinks#index"
    resources :drinks, only: [ :index, :create ]
  end

  # Kassenwart
  namespace :treasurer do
    root "dashboard#index"
    resources :members
    resources :transactions, only: [ :index, :new, :create ]
  end

  # Bierkassenwart
  namespace :inventory do
    root "dashboard#index"
    resources :products
    resources :purchases, only: [ :index, :new, :create ]
    resources :inventory_counts, only: [ :index, :new, :create ]
  end
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "kiosk/drinks#index"
end
