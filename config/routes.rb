Rails.application.routes.draw do

  # Public routes
  root 'welcome#home'
  get '/group_signup' => 'group_signups#new', as: :group_signup
  get '/sport_nomination' => 'awards#new_good_sports', as: :sport_nomination
  get '/sport_evaluation' => 'sports_evaluations#new', as: :sport_evaluation
  get '/incident' => 'incident_reports#new', as: :incident
  get '/spirit' => 'awards#new_spirit', as: :spirit
  get '/legend' => 'awards#new_volunteer', as: :legend
  get '/knockout_reference' => 'admin/info#knockout_reference', controller: "admin/info", as: :knockout_reference
  get '/ladder_reference' => 'admin/info#ladder_reference', controller: "admin/info", as: :ladder_reference
  get '/results_reference' => 'admin/info#results_reference', controller: "admin/info", as: :results_reference
  get 'static/:permalink' => 'pages#show', as: :static

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  } 

  # Public and general routes
  resources :pages, only: [:show]
  resources :lost_items, only: [:show, :index, :edit, :update] do
    collection do
      get :search
    end
  end

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
  resources :participants do
    collection do
      get :available_participants
    end
    member do
      patch :switch
    end
  end

  resources :participant_signups, only: [:new, :create] do
    collection do
      get :transfer
      post :create_transfer
    end
  end

  resources :group_signups, :only => [:new, :create]

  resources :sports_evaluations, :only => [:new, :create]
  resources :incident_reports, :only => [:new, :create]
  resources :awards do
    collection do
      get :new_good_sports
      get :new_spirit
      get :new_volunteer
      post :create_good_sports
      post :create_spirit
      post :create_volunteer
    end
  end

  resources :charts, only: [] do
    collection do
      get :admin_groups
      get :admin_participants
      get :admin_sport_entries
      get :admin_volunteers
      get :admin_group_stats
      get :admin_participant_stats
      get :admin_sport_entry_stats
      get :admin_volunteer_stats
      get :gc_participants
      get :gc_sport_entries
      get :evening_saturday_preferences
      get :evening_sunday_preferences
    end
  end

  # Admin routes
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
        get :gender_summary
        get :sport_integrity
      end
    end

    resource :tasks, :controller => "tasks" do
      collection do
        get :sports_draws
        post :allocate_restricted
        post :finalise_team_sports
        post :finalise_individual_sports
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
        get :edit_references
        patch :update_event
        patch :update_functionality
        patch :update_email
        patch :update_social
        patch :update_fees
        patch :update_divisions
        patch :update_sports_factors
        patch :update_website
        patch :update_references
        patch :purge_knockout_reference
        patch :purge_ladder_reference
        patch :purge_results_reference
        patch :purge_sports_reference
        patch :purge_sports_maps
      end
    end
    resources :pages
    resources :lost_items do
      member do
        patch :purge_photo
      end
    end
    resources :roles
    resources :timelines
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
        get :session_participants
        get :summary
        get :sport_summary
        get :payments
        get :volunteer_summary
      end
      member do
        post :invoice        
        patch :approve
        get :edit_approval
        patch :update_approval
      end
      resources :participants, only: [:index] do
        collection do
          get :drivers
        end
      end
    end
    resources :event_details, only: [:index, :show, :edit, :update] do
      member do
        patch :purge_file
        get :edit_warden_zone
        patch :update_warden_zone
      end
      collection do
        get :new_import
        post :import
        get :search
        get :uploads
        get :warden_zones
        get :buddy_groups
        get :orientation_details
        patch :update_multiple_orientations
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
    resources :warden_zones
    resources :participants do
      collection do
        get :new_import
        post :import
        get :new_ticket_import
        post :ticket_import
        get :tickets
        post :ticket_download
        post :ticket_updates
        post :ticket_reset
        get :ticket_full_extract
        get :search
        get :participant_audit
        get :participant_integrity
        get :wwccs
        get :day_visitors
        get :new_day_visitor
        post :create_day_visitor
      end
      member do
        get :new_voucher
        post :add_voucher
        patch :delete_voucher
        get :edit_day_visitor
        patch :update_day_visitor
        delete :destroy_day_visitor
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
      member do
        patch :purge_file
      end
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
      resources :round_robin_matches, only: [:index]
      member do
        patch :purge_file
      end
      collection do
        get :results
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

    resources :round_robin_matches do
      collection do
        get :matches
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
        get :search
        get :sat_coords
        get :sun_coords
        get :coord_notes
        get :sport_volunteers
        get :new_import
        post :import
      end
      member do
        get :collect
        get :return
        patch :update_collect
        patch :update_return
      end
      resources :sections, only: [:index] do
        collection do
          patch :add_section
        end
        member do
          delete :purge
        end
      end
    end

    resources :ballot_results, :only => [:index] do
      collection do
        get :summary
      end
    end

    resources :sports_evaluations
    resources :incident_reports
    resources :awards do
      collection do
        get :good_sports
        get :spirit
        get :volunteer_awards
        get :new_good_sports
        get :new_spirit
        get :new_volunteer
        post :create_good_sports
        post :create_spirit
        post :create_volunteer
      end
      member do
        get :edit_good_sports
        get :edit_spirit
        get :edit_volunteer
        patch :update_good_sports
        patch :update_spirit
        patch :update_volunteer
        patch :flag_good_sports
        patch :flag_spirit
        patch :flag_volunteer
        delete :destroy_good_sports
        delete :destroy_spirit
        delete :destroy_volunteer
      end
    end
  end

  # API routes
  namespace :api do
    resources :audit_trail, only: [:index]
    resources :groups, only: [:show]
    resources :event_details, only: [:show]
    resources :participants, only: [:show]
    resources :sport_entries, only: [:show] do
      resources :participants, controller: "participants_sport_entries", only: [:index]
    end
    resources :round_robin_matches, only: [:show]
    resources :sports, only: [:show]
    resources :grades, only: [:show]
    resources :sections, only: [:show]
    resources :sessions, only: [:show]
    resources :venues, only: [:show]
    resources :volunteer_types, only: [:show]
    resources :volunteers, only: [:show]
  end

  # Sport Coordinator routes
  namespace :sc do
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

    resources :sections, only: [:show, :index] do
      resources :round_robin_matches, only: [:index]  do
        collection do
          patch :update_multiple
          get :reset
        end
      end
    end
    
    resources :sports_evaluations, :only => [:new, :create]
    resources :incident_reports, :only => [:new, :create]
    resources :awards do
      collection do
        get :new_good_sports
        get :new_spirit
        get :new_volunteer
        post :create_good_sports
        post :create_spirit
        post :create_volunteer
      end
    end
  end
  
  # Group Coordinator routes
  namespace :gc do
    resource :info, :controller => "info" do
      collection do
        get :home
      end
    end
    resources :users do
      member do
        get :edit_password
        patch :update_password
      end
    end

    resources :groups, only: [:edit, :update]
    resources :groups_grades_filters, only: [:show] do
      member do
        post :hide_team
        post :hide_indiv
        delete :show_team
        delete :show_indiv
      end
    end
    resources :groups_grades_filters, only: [:show] do
      member do
        post :hide_team
        post :hide_indiv
        delete :show_team
        delete :show_indiv
      end
    end
    resources :group_fee_categories
    resources :event_details, only: [:edit, :update] do
      member do
        get :new_food_certificate
        get :new_covid_plan
        get :new_insurance
        patch :update_food_certificate
        patch :update_covid_plan
        patch :update_insurance
        patch :purge_food_certificate
        patch :purge_covid_plan
        patch :purge_insurance
      end
    end
    resources :mysyg_settings, only: [:edit, :update] do
      member do
        get :edit_team_sports
        get :edit_indiv_sports
        get :new_policy
        patch :update_team_sports
        patch :update_indiv_sports
        patch :update_policy
        patch :purge_policy
      end
    end
    resources :payments
    resources :group_extras
    resources :participant_extras
    resources :participants do
      resources :sport_entries, controller: "participants_sport_entries", only: [:create, :destroy]
      collection do
        get :new_import
        post :import
        get :search
        get :approvals
        get :drivers
        get :wwccs
        get :vaccinations
        get :group_fees
        get :sports_plan
        get :camping_preferences
        get :sport_notes
      end
      member do
        get :new_voucher
        get :edit_driver
        get :edit_wwcc
        get :edit_vaccination
        get :edit_fees
        get :edit_sports
        get :edit_camping_preferences
        get :edit_sport_notes
        post :add_voucher
        patch :delete_voucher
        patch :accept
        patch :reject
        patch :coming
        patch :update_driver
        patch :update_wwcc
        patch :update_vaccination
        patch :update_fees
        patch :update_camping_preferences
        patch :update_sport_notes
      end
    end
    resources :volunteers, only: [:index, :show, :edit, :update] do
      collection do
        get :search
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
      member do
        patch :confirm
      end
      collection do
        get :sports_draws
        get :sports_rules
      end
    end
    resources :sport_preferences, :controller => "sport_preferences", :only => [:index] do
      member do
        post :add_to_sport_entry
        post :create_sport_entry
        delete :remove_from_sport_entry
      end
    end
  end

  # Participant User routes 
  scope 'mysyg', as: 'mysyg' do
    get '/signup' => 'participant_signups#new', as: :generic_signup
    
    resources :users, controller: 'mysyg/users', only: [:edit, :update] do
      member do
        get :edit_password
        patch :update_password
      end
    end

    scope '/:group' do
      get '/signup' => 'participant_signups#new', :as => :signup
      get '/home' => 'mysyg/info#home', :as => :home
      get '/details' => 'mysyg/participants#edit', :as => :details
      get '/drivers' => 'mysyg/participants#drivers', as: :drivers
      get '/notes' => 'mysyg/participants#edit_notes', as: :notes
      get '/extras' => 'mysyg/participant_extras#index', :as => :extras
      get '/sports' => 'mysyg/sport_preferences#index', :as => :sports
      get '/volunteering' => 'mysyg/volunteers#index', :as => :volunteering
      get '/finance' => 'mysyg/info#finance', :as => :finance
 
      resources :participant_signups, controller: "participant_signups", only: [:new, :create]
      resource :info, :controller => "mysyg/info" do
        collection do
          get :home
          get :finance
        end
      end
      resources :participants, :controller => "mysyg/participants", :only => [:edit, :update] do
        member do
          get :new_voucher
          get :edit_notes
          get :drivers
          post :add_voucher
          patch :delete_voucher
          patch :update_drivers
          patch :update_notes
        end
      end
      resources :volunteers, :controller => "mysyg/volunteers", :only => [:index, :edit, :update]
      resources :sport_preferences, :controller => "mysyg/sport_preferences", only: [:index] do
        collection do
          patch :update_multiple
        end
      end
      resources :participant_extras, :controller => "mysyg/participant_extras", only: [:index] do
        collection do
          patch :update_multiple
        end
      end
    end
  end
end
