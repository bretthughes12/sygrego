class ParticipantSignupsController < ApplicationController

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
      @participant_signup.onsite = @group.onsite
      
      @groups = Group.mysyg_actives.map { |g| [ g.mysyg_selection_name, g.id ]}
    end
    
    # POST /participant_signups
    def create
      @participant_signup = ParticipantSignup.new(params[:participant_signup])
      @group = @participant_signup.group || Group.find_by_abbr("DFLT")

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

          unless @user.active
            if @participant_signup.participant.status == "Requiring Approval"
#              UserMailer.welcome_participant(@user).deliver_now
            else
              flash[:notice] = "Thank you for registering for State Youth Games"
              bypass_sign_in @user
              session["current_role"] = "participant"
              format.html { redirect_to edit_password_gc_user_path(@church_rep) }
            end
            
#            UserMailer.new_participant(@user).deliver_now if @participant_signup.participant.group.active
          end
  
        else
          format.html do
            flash[:notice] = 'There was a problem with your signup. Please check below for specific error messages'
            @groups = Group.mysyg_actives.map { |g| [ g.mysyg_selection_name, g.id ]}
            render "new"
          end
        end
      end
    end
  end
  