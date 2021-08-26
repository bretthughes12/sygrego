Rails.application.routes.draw do
  devise_for :users

  root 'admin/sports#index'

  namespace :admin do
    resources :sports
  end
end
