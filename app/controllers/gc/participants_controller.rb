class Gc::ParticipantsController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    
    layout "gc" 
  
    # GET /gc/participants
    def index
      @participants = @group.participants.accepted.
        order('coming desc, first_name, surname').load
  
      respond_to do |format|
        format.html do
          @participants = @participants.paginate(page: params[:page], per_page: 100)
          render layout: @current_role.name
        end
        format.csv  { render_csv "participant", "participant" }
      end
    end

    # GET /gc/participants/search
    def search
      @participants = @group.participants.accepted.
        search(params[:search]).
        order('coming desc, first_name, surname').
        paginate(page: params[:page], per_page: 100)
  
      respond_to do |format|
        format.html { render action: 'index', layout: @current_role.name }
      end
    end

    # GET /gc/participants/approvals
    def approvals
      @participants = @group.participants.requiring_approval.
        order("first_name, surname").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end
    
    # GET /gc/participants/drivers
    def drivers
      respond_to do |format|
        format.html do
          @participants = @group.participants.accepted.open_age.
            order("coming desc, driver desc, first_name, surname").load
    
          render layout: @current_role.name
        end
        format.pdf do
          @participants = @group.participants.accepted.coming.drivers.
            order("first_name, surname").load

          output = DriverReport.new.add_data(@group, @participants).to_pdf
          
          render_pdf output, 'drivers'
        end
      end
    end
    
    # GET /gc/participants/wwccs
    def wwccs
      @participants = @group.participants.accepted.open_age.
        order("coming desc, first_name, surname").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end
    
    # GET /gc/participants/vaccinations
    def vaccinations
      @participants = @group.participants.accepted.open_age.
        order("coming desc, first_name, surname").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end
    
    # GET /gc/participants/group_fees
    def group_fees
      @participants = @group.participants.accepted.coming.
        order("first_name, surname").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end
    
    # GET /gc/participants/sports_plan
    def sports_plan
      @participants = @group.participants.accepted.coming.playing_sport.
        order("first_name, surname").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
        format.csv  { render_csv "sports_plan", "sports_plan" }
      end
    end
    
    # GET /gc/participants/1
    def show
      render layout: @current_role.name
    end
  
    # GET /gc/participants/new
    def new
      respond_to do |format|
        format.html { render layout: @current_role.name }
      end
    end
  
    # GET /gc/participants/1/edit
    def edit
      render layout: @current_role.name
    end
  
    # GET /gc/participants/1/edit_driver
    def edit_driver
      render layout: @current_role.name
    end
  
    # GET /gc/participants/1/edit_wwcc
    def edit_wwcc
      render layout: @current_role.name
    end
  
    # GET /gc/participants/1/edit_vaccination
    def edit_vaccination
      render layout: @current_role.name
    end
  
    # GET /gc/participants/1/edit_fees
    def edit_fees
      render layout: @current_role.name
    end
  
    # GET /gc/participants/1/edit_sports
    def edit_sports
      @grades = @participant.available_grades
      @sections = @participant.available_sections
      @sport_entry = SportEntry.new

      render layout: @current_role.name
    end
  
    # POST /admin/participants
    def create
      @participant = Participant.new(participant_params)
      @participant.early_bird = @settings.early_bird
      @participant.group_id = @group.id
      @participant.updated_by = current_user.id

      respond_to do |format|
          if @participant.save
              flash[:notice] = 'Participant was successfully created.'
              format.html { render action: "edit", layout: @current_role.name }
          else
              format.html { render action: "new", layout: @current_role.name }
          end
      end
    end

    # PATCH /gc/participants/1
    def update
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to gc_participants_url }
        else
          format.html { render action: "edit", layout: @current_role.name }
        end
      end
    end

    # PATCH /gc/participants/1/update_driver
    def update_driver
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_driver_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to drivers_gc_participants_url }
        else
          format.html { render action: "edit_driver", layout: @current_role.name }
        end
      end
    end

    # PATCH /gc/participants/1/update_wwcc
    def update_wwcc
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_wwcc_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to wwccs_gc_participants_url }
        else
          format.html { render action: "edit_wwcc", layout: @current_role.name }
        end
      end
    end

    # PATCH /gc/participants/1/update_vaccination
    def update_vaccination
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_vaccination_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to vaccinations_gc_participants_url }
        else
          format.html { render action: "edit_vaccination", layout: @current_role.name }
        end
      end
    end

    # PATCH /gc/participants/1/update_fees
    def update_fees
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_fees_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to group_fees_gc_participants_url }
        else
          format.html { render action: "edit_fees", layout: @current_role.name }
        end
      end
    end

    # PATCH /gc/participants/1/accept
    def accept
      @participant.updated_by = current_user.id
      @participant.accept!
      user = @participant.users.first
      token = user.get_reset_password_token

      respond_to do |format|
        flash[:notice] = 'Participant was accepted into your group.'
        UserMailer.accept_participant(@participant, @group, token).deliver_now
        format.html { redirect_to approvals_gc_participants_url }
      end
    end

    # PATCH /gc/participants/1/reject
    def reject
      @participant.updated_by = current_user.id
      @participant.reject!

      respond_to do |format|
        flash[:notice] = 'Participant was rejected from your group.'
        UserMailer.reject_participant(@participant, @group).deliver_now
        format.html { redirect_to approvals_gc_participants_url }
      end
    end
  
    # PATCH /gc/participants/1/coming
    def coming
      @participant.updated_by = current_user.id
      @participant.coming = true
      @participant.save

      respond_to do |format|
        format.html { redirect_to gc_participants_url }
      end
    end

    # DELETE /admin/participants/1
    def destroy
      @participant.updated_by = current_user.id

      @participant.destroy

      respond_to do |format|
        format.html { redirect_to gc_participants_url }
      end
    end
  
    # GET /gc/participants/new_import
    def new_import
      @participant = Participant.new
      render layout: @current_role.name
    end
  
    # POST /gc/participants/import
    def import
      if params[:participant] && params[:participant][:file].path =~ %r{\.csv$}i
        result = Participant.import_gc(params[:participant][:file], @group, current_user)

        flash[:notice] = "Participants upload complete: #{result[:creates]} participants created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to gc_participants_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
        @participant = Participant.new

        respond_to do |format|
          format.html { render action: "new_import", layout: @current_role.name }
        end
      end
    end

    # GET /gc/participants/1/new_voucher
    def new_voucher
      render layout: @current_role.name
    end
  
    # POST /gc/participants/1/add_voucher
    def add_voucher
      if params[:participant] && !params[:participant][:voucher_name].blank?
        name = (params[:participant][:voucher_name])
        name.upcase!
        voucher = Voucher.find_by_name(name)

        if voucher && voucher.valid_for?(@participant)
          @participant.voucher = voucher
          @participant.save

          flash[:notice] = "Voucher added to participant"

          respond_to do |format|
            format.html { redirect_to edit_gc_participant_url(@participant) }
          end
        else
          flash[:notice] = "Voucher is not valid for this participant"

          respond_to do |format|
            format.html { render action: "new_voucher", layout: @current_role.name }
          end
        end
      else
        flash[:notice] = "Voucher is not valid for this participant"

        respond_to do |format|
          format.html { render action: "new_voucher", layout: @current_role.name }
        end
      end
    end
  
    # PATCH /gc/participants/1/delete_voucher
    def delete_voucher
      if @participant.voucher
        @participant.voucher_id = nil
        @participant.save
      
        flash[:notice] = "Voucher deleted"

        respond_to do |format|
          format.html { redirect_to edit_gc_participant_url(@participant) }
        end
      else
        respond_to do |format|
          format.html { redirect_to edit_gc_participant_url(@participant) }
        end
      end
    end

    private
  
    def participant_params
      params.require(:participant).permit(
        :first_name, 
        :surname,
        :coming,
        :lock_version,
        :age,
        :gender,
        :coming_friday,
        :coming_saturday,
        :coming_sunday,
        :coming_monday,
        :address,
        :suburb,
        :postcode,
        :phone_number,
        :medicare_number,
        :medical_info,
        :medications,
        :allergies,
        :years_attended,
        :email,
        :spectator,
        :onsite,
        :helper,
        :group_coord,
        :email,
        :mobile_phone_number,
        :dietary_requirements,
        :emergency_contact,
        :emergency_relationship,
        :emergency_phone_number,
        :amount_paid
      )
    end

    def participant_driver_params
      params.require(:participant).permit(
        :lock_version,
        :driver,
        :number_plate
      )
    end
  
    def participant_wwcc_params
      params.require(:participant).permit(
        :lock_version,
        :wwcc_number
      )
    end
  
    def participant_vaccination_params
      params.require(:participant).permit(
        :lock_version,
        :vaccinated,
        :vaccination_document,
        :vaccination_sighted_by
      )
    end
  
    def participant_fees_params
      params.require(:participant).permit(
        :lock_version,
        :amount_paid
      )
    end
  end
