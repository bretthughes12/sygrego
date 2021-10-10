class ApplicationController < ActionController::Base

    before_action :get_settings

    def get_settings
        @settings ||= Setting.first
    end
    
    def render_csv(filename = nil, action = nil)
        filename ||= params[:action]
        filename += '.csv'
        action ||= params[:action]
      
        headers["Content-Type"] ||= 'text/csv'
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
      
        render layout: false, action: action
    end
   
    def current_ability
        @current_ability ||= Ability.new(current_user, session)
    end

    def home_url(user)
        case
          when user.nil?
            new_user_session_url

          else 
            role = session["current_role"]
            if role == "admin"
                admin_sports_url
            elsif role == "gc" || role == "church_rep"
                home_gc_info_url
            else
                home_gc_info_url
            end
        end
    end
    
    rescue_from CanCan::AccessDenied do |exception|
        case
        when current_user.nil?
            flash[:notice] = "Please sign in to continue"
            redirect_to home_url(current_user)

        else
            flash[:notice] = "You are not authorised to perform the requested function"
            redirect_to home_url(current_user)
        end
    end
end