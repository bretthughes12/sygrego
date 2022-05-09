class ApplicationController < ActionController::Base

    before_action :get_settings
    before_action :current_role

    def get_settings
        @settings ||= Setting.first
    end

    def authorize_xml
        authenticate_or_request_with_http_basic do |username,password|
            resource = User.find_by_email(username)
            if resource && resource.valid_password?(password) && resource.role?(:admin)
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

    def render_pdf(data, filename = nil)
        filename ||= params[:action]
        filename += '.pdf'
      
        send_data data, filename: "#{filename}", 
                        type: "application/pdf"
    end
    
    def current_ability
        @current_ability ||= Ability.new(current_user, session)
    end

    def current_role 
        if session["current_role"]
            @current_role ||= Role.find_by_name(session["current_role"].to_s)
        elsif current_user
            @current_role ||= Role.find_by_name(current_user.default_role.to_s)
        end
    end

    def home_url(user)
        case
          when user.nil?
            new_user_session_url

          else 
            role = session["current_role"]
            group_abbr = session["current_group"]
            group = Group.find_by_abbr(group_abbr)
            participant_id = session["current_participant"]
            participant = Participant.where(id: participant_id).first

            if role == "admin"
                home_admin_info_url
            elsif role == "gc" || role == "church_rep"
                home_gc_info_url
            elsif participant
                home_mysyg_info_url(group: participant.group.mysyg_setting.mysyg_name)
            elsif group
                home_mysyg_info_url(group: group.mysyg_setting.mysyg_name)
            else
                new_user_session_url
            end
        end
    end

    def find_group
        if @group.nil?
            if session["current_group"] && !session["current_group"].blank?
              @group = Group.find_by_abbr(session["current_group"])
            end
        end

        if @group.nil?
            if current_user && current_user.groups.count > 0
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