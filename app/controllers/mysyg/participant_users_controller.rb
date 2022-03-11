class Mysyg::ParticipantUsersController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    before_filter :find_group

    actions :new, :create, :edit, :update

    layout 'participant'
    
    def new
      @participant_user = ParticipantUser.new(group_id: @group.id)
      @participant_user.status = @group.approve_option == "Tolerant" ? "Accepted" : "Requiring Approval"
      @participant_user.age = 30
      @participant_user.coming_friday = true
      @participant_user.coming_saturday = true
      @participant_user.coming_sunday = true
      @participant_user.coming_monday = true
      @participant_user.coming = true
      @participant_user.onsite = @group.onsite
      @participant = @participant_user.participant
      
      @groups = Group.mysyg_actives.map { |g| [ g.mysyg_selection_name, g.id ]}
      
      new!
    end
  
    def create
      @participant = @participant_user.participant
      @group = @participant_user.group || Group.find_by_abbr("DFLT")
      case
        when !@group.active
          @participant_user.status = "Requiring Approval"
        when @group.mysyg_setting.approve_option == "Tolerant"
          @participant_user.status = "Accepted"
        when @group.mysyg_setting.approve_option == "Strict"
          @participant_user.status = "Requiring Approval"
        when @participant.new_record?
          @participant_user.status = "Requiring Approval"
        else 
          @participant_user.status = "Accepted"
      end
      
      respond_to do |format|
        if @participant_user.save
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
  
    def edit
      @participant_user = ParticipantUser.locate(@current_user)
      @participant = @participant_user.participant
    end
  
    def update
      @participant_user = ParticipantUser.locate(@current_user)
  
      respond_to do |format|
        old_participant = @participant_user.participant.dup
        if @participant_user.update_attributes(params[:participant_user])
          flash[:notice] = 'Details successfully updated.'
          format.html { redirect_to mysyg_home_url(group: @group.mysyg_name) }
        else
          format.html do
            flash[:notice] = 'Update failed. See below for the reasons.'
            @participant = @participant_user.participant
            render action: "edit"
          end
        end
      end
    end
  
    def drivers
      @participant_user = ParticipantUser.locate(@current_user)
      @participant = @participant_user.participant
    end
  
    def update_drivers
      @participant_user = ParticipantUser.locate(@current_user)
      @participant = @participant_user.participant
  
      respond_to do |format|
        if @participant_user.update_attributes(params[:participant_user])
          if @participant.driver_signature 
            @participant.driver_signature_date = Time.now
            @participant.save
          end
          log(@participant_user.participant, "UPDATE")
          flash[:notice] = 'Details successfully updated.'
          format.html { redirect_to mysyg_home_url(group: @group.mysyg_name) }
        else
          format.html do
            flash[:notice] = 'Update failed. See below for the reasons.'
            @participant = @participant_user.participant
            render action: "drivers", layout: 'mysyg_drivers'
          end
        end
      end
    end
  
    def create_consent
      @participant_user = ParticipantUser.find(params[:id])
  #    @participant_user.send_attributes(params[:participant_user])
  #    @participant_user.validate_consent_provided
  
      respond_to do |format|
        if @participant_user.record_consent(params[:participant_user])
          unless @participant_user.user.active
            if @participant_user.participant.status == "Accepted"
              @participant_user.user.activate
            else
              UserMailer.welcome_participant(@participant_user.user).deliver_now
            end
            
            UserMailer.new_participant(@participant_user.user).deliver_now if @participant_user.participant.group.active
          end
  
          FeeAuditTrail.generate(nil, @participant_user.participant, @participant_user.user)
  
          flash[:notice] = 'You have signed up successfully. Check your email for your user-id and password'
          format.html { redirect_to mysyg_login_url(group: @group.mysyg_name) }
        else
          flash[:notice] = 'You must tick all of these boxes to complete your signup' 
          format.html { render action: "consent" }
        end
      end
    end
end
  