Rails.application.routes.draw do
  resource :sessions, only: %i(create destroy)
  resources :users
end
