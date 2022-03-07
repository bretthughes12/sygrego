Rails.application.routes.draw do

  # Public routes
  root 'welcome#home'
  get '/group_signup' => 'group_signups#new', :as => :group_signup
  get 'static/:permalink' => 'pages#show', :as => :static

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  } 

  resources :pages, only: [:show]

  resources :roles do
    collection do
      get :available_roles
    end
    member do
      patch :switch
    end
  end
  resources :groups, only: [:index] do
    collection do
      get :available_groups
    end
    member do
      patch :switch
    end
  end

  resources :group_signups, :only => [:new, :create]

  resources :charts, only: [] do
    collection do
      get :admin_groups
      get :admin_participants
      get :admin_group_stats
      get :admin_participant_stats
      get :admin_sport_entry_stats
      get :admin_volunteer_stats
      get :gc_participants
      get :evening_saturday_preferences
      get :evening_sunday_preferences
    end
  end

  namespace :admin do
    resource :info, :controller => "info" do
      collection do
        get :home
        get :tech_stats
        get :event_stats
      end
    end

    resource :reports, :controller => "reports" do
      collection do
        get :finance_summary
        get :service_preferences
        get :fees
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
    resources :pages
    resources :roles
    resources :users do
      member do
        get :edit_password
        patch :update_password
        get :profile
        patch :update_profile
      end
      collection do
        get :search
      end
      resources :roles, only: [:index] do
        member do
          patch :add
          delete :purge
        end
      end
      resources :groups, only: [:index] do
        collection do
          patch :add_group
        end
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
        get :approvals
      end
      member do
        patch :approve
      end
    end
    resources :event_details, only: [:index, :show, :edit, :update] do
      member do
        patch :purge_file
      end
      collection do
        get :new_import
        post :import
        get :search
      end
    end
    resources :mysyg_settings, only: [:index, :show, :edit, :update] do
      collection do
        get :new_import
        post :import
        get :search
      end
    end
    resources :rego_checklists, only: [:index, :show, :edit, :update] do
      collection do
        get :search
      end
    end

    resources :payments do
      member do
        patch :reconcile
      end
    end
    resources :vouchers
    resources :participants do
      collection do
        get :new_import
        post :import
        get :search
      end
    end

    resources :sport_entries do
      collection do
        get :new_import
        post :import
      end
      resources :participants, controller: "participants_sport_entries", only: [:create, :destroy] do
        member do
          patch :make_captain
        end
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

    resources :volunteer_types do
      collection do
        get :new_import
        post :import
      end
    end
    resources :volunteers do
      collection do
        get :new_import
        post :import
      end
    end
  end

  namespace :api do
    resources :audit_trail, only: [:index]
    resources :groups, only: [:show]
    resources :event_details, only: [:show]
    resources :participants, only: [:show]
    resources :sport_entries, only: [:show]
    resources :sports, only: [:show]
    resources :grades, only: [:show]
    resources :sections, only: [:show]
    resources :sessions, only: [:show]
    resources :venues, only: [:show]
    resources :volunteer_types, only: [:show]
    resources :volunteers, only: [:show]
  end

  namespace :gc do
    resource :info, :controller => "info" do
      collection do
        get :home
      end
    end
    resources :users, only: [:edit, :update] do
      member do
        get :edit_password
        patch :update_password
      end
    end

    resources :groups, only: [:edit, :update]
    resources :event_details, only: [:edit, :update] do
      member do
        patch :purge_file
      end
    end
    resources :mysyg_settings, only: [:edit, :update]
    resources :payments
    resources :participants do
      collection do
        get :new_import
        post :import
        get :search
      end
    end
    resources :volunteers, only: [:index, :show, :edit, :update] do
      collection do
        get :available
      end
      member do
        patch :release
      end
    end
    resources :sport_entries do
      resources :participants, controller: "participants_sport_entries", only: [:create, :destroy] do
        member do
          patch :make_captain
        end
      end
    end
  end
end

