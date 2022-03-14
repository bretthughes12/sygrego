class ParticipantSignupsController < ApplicationController

    before_action :find_group

    layout 'users'
  
    # GET /participant_signups/new
    def new
      @participant_signup = ParticipantSignup.new(group_id: @group.id)
      @participant_signup.status = @group.mysyg_setting.approve_option == "Tolerant" ? "Accepted" : "Requiring Approval"
      @participant_signup.age = 30
      @participant_signup.coming_friday = true
      @participant_signup.coming_saturday = true
      @participant_signup.coming_sunday = true
      @participant_signup.coming_monday = true
      @participant_signup.coming = true
      @participant_signup.onsite = @group.onsite
      @participant = @participant_signup.participant
      
      @groups = Group.mysyg_actives.map { |g| [ g.mysyg_selection_name, g.id ]}
    end
    
    # POST /participant_signups
    def create
      @participant = @participant_signup.participant
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
          ParticipantExtra.initialise_for_participant(@participant)
          flash[:notice] = 'Please read the following carefully'
          format.html { redirect_to mysyg_disclaimer_url(group: @group.mysyg_name, participant_id: @participant.id) }
        else
          format.html do
            flash[:notice] = 'There was a problem with your signup. Please check below for specific error messages'
            @groups = Group.mysyg_actives.map { |g| [ g.mysyg_selection_name, g.id ]}
            if @group
              render "new", locals: { group: @group.mysyg_name }
            else
              render "new"
            end
          end
        end
      end
    end
  end
  