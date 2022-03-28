class Gc::ParticipantsController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    
    layout "gc" 
  
    # GET /gc/participants
    def index
      @participants = @group.participants.accepted.
        order('coming desc, surname, first_name').load
  
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
        order('coming desc, surname, first_name').
        paginate(page: params[:page], per_page: 100)
  
      respond_to do |format|
        format.html { render action: 'index', layout: @current_role.name }
      end
    end

    # GET /gc/participants/approvals
    def approvals
      @participants = @group.participants.requiring_approval.
        order("surname, first_name").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end
    
    # GET /gc/participants/drivers
    def drivers
      @participants = @group.participants.accepted.open_age.
        order("coming desc, driver desc, surname, first_name").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end
    
    # GET /gc/participants/wwccs
    def wwccs
      @participants = @group.participants.accepted.open_age.
        order("coming desc, surname, first_name").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end
    
    # GET /gc/participants/vaccinations
    def vaccinations
      @participants = @group.participants.open_age.
        order("coming desc, surname, first_name").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
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
        :years_attended,
        :email,
        :spectator,
        :onsite,
        :helper,
        :group_coord,
        :driver,
        :number_plate,
        :email,
        :mobile_phone_number,
        :dietary_requirements,
        :emergency_contact,
        :emergency_relationship,
        :emergency_phone_number,
        :amount_paid,
        :wwcc_number,
        :driver_signature,
        :driver_signature_date
      )
    end
end
