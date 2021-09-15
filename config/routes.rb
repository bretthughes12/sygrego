Rails.application.routes.draw do
  root 'admin/sports#index'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  } 

  namespace :admin do
    resource :info, :controller => "info" do
      collection do
        get :tech_stats
      end
    end

    resources :settings, only: [:show, :edit, :update] do
      member do
        get :edit_functionality
      end
    end
    resources :audit_trail, only: [:index]

    resources :sports
    resources :sessions
    resources :venues
  end
end
