Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  resources :authors, only: %i[new create]

  resources :books, only: %i[index show] do
    resources :reviews, only: :create
  end

  scope module: :creator, path: :author, as: :author do
    get "dashboard", to: "dashboards#show"
    resources :books, only: %i[new create]
    resources :categories, only: %i[new create]
  end

  mount ActionCable.server => "/cable"

  root "books#index"
end
