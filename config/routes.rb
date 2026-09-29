Rails.application.routes.draw do
  concern :shareable do |options|
    resources :shares, only: %i[create update destroy], controller: options[:controller]
  end

  resources :entries do
    concerns :shareable, controller: "entry_shares"
  end

  resources :characters do
     concerns :shareable, controller: "character_shares"
  end

  resources :users
  resource :session

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
