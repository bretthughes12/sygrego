Rails.application.routes.draw do
  root 'admin/sports#index'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  } 

  namespace :admin do
    resources :sports
    resources :settings, only: [:show, :edit, :update]
  end
end
