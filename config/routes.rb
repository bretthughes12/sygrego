Rails.application.routes.draw do

  # Public routes
  root 'admin/sports#index'
  resources :pages, only: [:show]
  get 'static/:permalink' => 'pages#show', :as => :static

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
        get :edit_event
        get :edit_functionality
        get :edit_email
        get :edit_social
        get :edit_fees
        get :edit_divisions
        get :edit_sports_factors
        get :edit_website
        patch :update_event
        patch :update_functionality
        patch :update_email
        patch :update_social
        patch :update_fees
        patch :update_divisions
        patch :update_sports_factors
        patch :update_website
      end
    end
    resources :audit_trail, only: [:index]
    resources :pages
    resources :roles
    resources :users do
      resources :roles, only: [:index] do
        member do
          patch :add
          delete :purge
        end
      end
    end

    resources :groups do
      collection do
        get :new_import
        post :import
        get :search
      end
    end

    resources :sports do
      collection do
        get :new_import
        post :import
      end
    end
    resources :grades do
      collection do
        get :new_import
        post :import
      end
    end
    resources :sections do
      member do
        patch :purge_file
      end
      collection do
        get :new_import
        post :import
      end
    end
    resources :sessions do
      collection do
        get :new_import
        post :import
      end
    end
    resources :venues do
      collection do
        get :new_import
        post :import
      end
    end
  end

  namespace :gc do
    resource :info, :controller => "info" do
      collection do
        get :home
      end
    end

    resources :groups, only: [:edit, :update]
  end
end

