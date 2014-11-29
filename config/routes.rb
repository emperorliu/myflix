Myflix::Application.routes.draw do
  require 'sidekiq/web'

  get 'ui(/:action)', controller: 'ui'

  root to: 'pages#front'
  get '/home', to: 'videos#index'

  resources :videos, only: [:show] do |variable|
    collection do
      get :search, to: 'videos#search'
    end
    resources :reviews, only: [:create]
  end
  resources :categories, only: [:show]

  resources :users, only: [:show]
  get 'people', to: 'relationships#index'
  resources :relationships, only: [:destroy, :create]

  get '/register', to: 'users#new'
  get '/register/:token', to: 'users#new_with_invitation_token', as: 'register_with_token'
  resources :users, only: [:create]

  get '/sign_in', to: 'sessions#new'
  resources :sessions, only: [:create]
  get '/sign_out', to: 'sessions#destroy'

  resources :queue_items, only: [:create, :destroy]
  get '/my_queue', to: 'queue_items#index'
  post 'update_queue', to: 'queue_items#update_queue'

  get 'forgot_password', to: 'forgot_passwords#new'
  resources :forgot_passwords, only: [:create]
  get 'forgot_password_confirmation', to: "forgot_passwords#confirm"

  resources :password_resets, only: [:show, :create]
  get 'expired_token', to: 'pages#expired_token'

  resources :invitations, only: [:new, :create]

  mount Sidekiq::Web, at: '/sidekiq'
end
