Rails.application.routes.draw do
  root "landing#index", constraints: ->(req) { req.subdomain.blank? || req.subdomain == "www" }
  root "kiosk/drinks#index", constraints: ->(req) { req.subdomain.present? && req.subdomain != "www" }, as: :subdomain_root
  post "/kontakt", to: "landing#contact", as: :landing_contact,
    constraints: ->(req) { req.subdomain.blank? || req.subdomain == "www" }

  get "landing/index"
  devise_for :members, controllers: {
    sessions: "members/sessions"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Super Admin
  namespace :super_admin do
    root "dashboard#index"
    resources :organizations do
      resources :memberships, only: [ :new, :create, :destroy ]
    end
  end

  # Kiosk - no login
  constraints subdomain: /\A(?!www|super_admin)\w[\w-]*\z/ do
    namespace :kiosk do
      root "drinks#index"
      resources :drinks, only: [ :index ] do
        collection do
          post :add_to_cart
          post :checkout
          post :remove_from_cart
          delete :clear_cart
        end
      end
      resources :payments, only: [ :show ]
    end
    resources :mixed_crates, only: [ :create ]
  end

  # Kassenwart
  namespace :treasurer do
    root "dashboard#index"
    resources :members, only: [ :index, :new, :create, :edit, :update, :destroy ]
    resources :transactions, only: [ :index, :new, :create, :edit, :update, :destroy ]
    resource :settings, only: [ :show, :update ]
    resources :requests, only: [ :index, :show ] do
      member do
        post :approve
        post :reject
      end
    end
  end

  # Bierkassenwart
  namespace :inventory do
    root "dashboard#index"
    resources :products
    resources :purchases, only: [ :index, :new, :create, :edit, :update, :destroy ]
    resources :inventory_counts, only: [ :index, :new, :create, :destroy ]
    resources :mixed_crates
  end

  # Mitgliederbereich
  namespace :member_area do
    root "dashboard#index"
    resources :requests, only: [ :index, :new, :create, :show ]
    resource :profile, only: [ :show, :edit, :update ]
  end
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
end
