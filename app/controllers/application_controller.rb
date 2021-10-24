class ApplicationController < ActionController::Base

    before_action :get_settings

    def get_settings
        @settings ||= Setting.first
    end

    def authorize_xml
        authenticate_or_request_with_http_basic do |username,password|
        resource = User.find_by_email(username)
        if resource.valid_password?(password)
            sign_in :user, resource
        end
        end
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

    def find_group
        if @group.nil?
            if session["current_group"]
              @group = Group.find_by_abbr(session["current_group"])
            elsif current_user.groups.count > 0
              @group = current_user.groups.first
            else
              @group = Group.first
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