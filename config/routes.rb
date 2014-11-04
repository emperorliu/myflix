Myflix::Application.routes.draw do
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

  get '/register', to: 'users#new'
  resources :users, only: [:create]

  get '/sign_in', to: 'sessions#new'
  resources :sessions, only: [:create]
  get '/sign_out', to: 'sessions#destroy'

  resources :queue_items, only: [:create, :destroy]
  get 'my_queue', to: 'queue_items#index'
end
