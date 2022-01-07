class Admin::ParticipantsController < ApplicationController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout "admin"
  
    # GET /admin/participants
    def index
      @participants = Participant.
        order(:surname, :first_name).load
  
      respond_to do |format|
        format.html { @participants = @participants.paginate(page: params[:page], per_page: 100) }
        format.csv  { render_csv "participant", "participant" }
      end
    end

    # GET /admin/participants/search
    def search
      @participants = Participant.
        search(params[:search]).
        order(:surname, :first_name).
        paginate(page: params[:page], per_page: 100)
  
      respond_to do |format|
        format.html { render action: 'index' }
      end
    end
    
    # GET /admin/participants/1
    def show
    end
  
    # GET /admin/participants/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/participants/1/edit
    def edit
    end
  
    # POST /admin/participants
    def create
        @participant = Participant.new(participant_params)
        @participant.updated_by = current_user.id

        respond_to do |format|
            if @participant.save
                flash[:notice] = 'Participant was successfully created.'
                format.html { render action: "edit" }
            else
                format.html { render action: "new" }
            end
        end
    end
  
    # PATCH /admin/participants/1
    def update
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_params)
          flash[:notice] = 'Participant was successfully updated.'
          format.html { redirect_to admin_participants_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/participants/1
    def destroy
        @participant.updated_by = current_user.id

#        if @participant.sections.empty?
            @participant.destroy
  
            respond_to do |format|
                format.html { redirect_to admin_participants_url }
            end
        
#          else
#            flash[:notice] = "Can't delete, as sections exist"
#        
#            respond_to do |format|
#                format.html { redirect_to admin_participants_url }
#            end
#        end
    end
  
    # GET /admin/participants/new_import
    def new_import
      @participant = Participant.new
    end
  
    # POST /admin/participants/import
    def import
      if params[:participant] && params[:participant][:file].path =~ %r{\.csv$}i
        result = Participant.import(params[:participant][:file], current_user)

        flash[:notice] = "Participants upload complete: #{result[:creates]} participants created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_participants_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
        @participant = Participant.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end

private
  
    def participant_params
      params.require(:participant).permit(
        :group_id, 
        :first_name, 
        :surname,
        :coming,
        :lock_version,
        :age,
        :gender,
        :days,
        :address,
        :suburb,
        :postcode,
        :phone_number,
        :medicare_number,
        :medical_info,
        :medications,
        :years_attended,
        :email,
        :spectator,
        :onsite,
        :helper,
        :group_coord,
        :sport_coord,
        :guest,
        :withdrawn,
        :fee_when_withdrawn,
        :late_fee_charged,
        :driver,
        :number_plate,
        :early_bird,
        :email,
        :mobile_phone_number,
        :dietary_requirements,
        :emergency_contact,
        :emergency_relationship,
        :emergency_phone_number,
        :amount_paid,
        :status,
        :wwcc_number,
        :driver_signature,
        :driver_signature_date
      )
    end
end
