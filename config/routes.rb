Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  } 

  root 'admin/sports#index'

  namespace :admin do
    resources :sports
  end
end
