Rails.application.routes.draw do
  root 'admin/sports#index'

  namespace :admin do
    resources :sports
  end
end
