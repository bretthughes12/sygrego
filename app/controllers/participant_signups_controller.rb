class ParticipantSignupsController < ApplicationController

    before_action :find_group

    layout 'users'
  
    # GET /participant_signups/new
    def new
      @participant_signup = ParticipantSignup.new
      @participant_signup.age = 30
      @participant_signup.coming_friday = true
      @participant_signup.coming_saturday = true
      @participant_signup.coming_sunday = true
      @participant_signup.coming_monday = true
      @participant_signup.coming = true
      @participant_signup.onsite = @group.event_detail.onsite
      @participant_signup.group_id = @group.id
      
      @groups = Group.mysyg_actives.map { |g| [ g.mysyg_selection_name, g.id ]}
    end
    
    # POST /participant_signups
    def create
      group_name = params[:group]
      @participant_signup = ParticipantSignup.new(params[:participant_signup])
      @group = @participant_signup.group || Group.find_by_abbr("DFLT")
      @participant = @participant_signup.participant

      case
      when !@group.active
        @participant_signup.status = "Requiring Approval"
      when @group.mysyg_setting.approve_option == "Tolerant"
        @participant_signup.status = "Accepted"
      when @group.mysyg_setting.approve_option == "Strict"
        @participant_signup.status = "Requiring Approval"
      when @participant.new_record?
        @participant_signup.status = "Requiring Approval"
      else 
        @participant_signup.status = "Accepted"
      end
      
      respond_to do |format|
        if @participant_signup.save
          @user = @participant_signup.user 

          UserMailer.welcome_participant(@user, @participant).deliver_now

          if @participant.status == "Requiring Approval"
            flash[:notice] = "Thank you for registering for State Youth Games. Check your email for instructions for what comes next."
            format.html do 
              redirect_to mysyg_signup_url(group: group_name)
            end
          else
            flash[:notice] = "Thank you for registering for State Youth Games"
            bypass_sign_in @user
            session["current_role"] = "participant"
            session["current_group"] = @group.id
            session["current_participant"] = @participant.id
            format.html do
              if @participant_signup.new_user
                redirect_to edit_password_mysyg_user_path(@user)
              else
                redirect_to root_url(current_user)
              end
            end
          end
          
          UserMailer.new_participant(@user, @participant).deliver_now if @participant_signup.participant.group.active
  
        else
          format.html do
            flash[:notice] = 'There was a problem with your signup. Please check below for specific error messages'
            @groups = Group.mysyg_actives.map { |g| [ g.mysyg_selection_name, g.id ]}
            render "new"
          end
        end
      end
    end

    private

    def find_group
      ms = MysygSetting.find_by_mysyg_name(params[:group])
      if ms.nil?
        ms = MysygSetting.find_by_mysyg_name("nogroup")
      end

      @group = ms.group unless ms.nil?
      
      unless @group
        raise ActiveRecord::RecordNotFound.new('Could not find your group. Please check the link with your group coordinator.')
      end
    end
  end
  