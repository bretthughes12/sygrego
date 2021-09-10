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

    resources :sports
    resources :settings, only: [:show, :edit, :update]
    resources :audit_trail, only: [:index]
    resources :sessions
  end
end
