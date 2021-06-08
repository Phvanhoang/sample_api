Rails.application.routes.draw do
  resource :sessions, only: %i(create destroy)
  resources :users, except: %i(new edit)
  resources :microposts, only: %i(create destroy)
  resources :relationships, only: %i(create destroy)
end
