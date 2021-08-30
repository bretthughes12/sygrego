Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  } 

  root 'admin/sports#index'

  namespace :admin do
    resources :sports
  end
end
