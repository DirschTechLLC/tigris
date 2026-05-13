Rails.application.routes.draw do
  resource  :session,   only: [:new, :create, :destroy]
  resources :passwords, param: :token, only: [:new, :create, :edit, :update]

  get "dashboard", to: "dashboard#show", as: :dashboard

  resources :organizations, param: :slug, only: [:new, :create, :show, :edit, :update] do
    resources :memberships, only: [:index, :create, :destroy]
    resources :api_keys,    only: [:index, :create, :destroy]
    resources :submissions, only: [:index, :show]
  end

  namespace :api do
    namespace :v1 do
      resources :submissions, only: [:create]
    end
  end

  root "dashboard#show"
  get "up" => "rails/health#show", as: :rails_health_check
end
