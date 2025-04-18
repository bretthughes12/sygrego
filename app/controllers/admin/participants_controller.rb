class Admin::ParticipantsController < AdminController

  load_and_authorize_resource
  before_action :authenticate_user!
  
  # GET /admin/participants
  def index
    @participants = Participant.
      order('coming desc, first_name, surname').load

    respond_to do |format|
      format.html { @participants = @participants.paginate(page: params[:page], per_page: 100) }
      format.xlsx { render xlsx: "index", filename: "participants.xlsx" }
    end
  end

  # GET /admin/participants/search
  def search
    @participants = Participant.
      search(params[:search]).
      order('coming desc, first_name, surname').
      load

    @participants = @participants.paginate(page: params[:page], per_page: 100)

    respond_to do |format|
      format.html { render action: 'index' }
    end
  end
  
  # GET /admin/participants/wwccs
  def wwccs
    @participants = Participant.coming.accepted.open_age.
      order("first_name, surname").load

    respond_to do |format|
      format.html { @participants = @participants.paginate(page: params[:page], per_page: 100) }
      format.xlsx { render xlsx: "wwccs", template: "admin/participants/wwccs" }
    end
  end

  # GET /admin/group/1/participants/drivers
  def drivers
    @group = Group.find(params[:group_id])

    respond_to do |format|
      format.html do
        @participants = @group.participants.accepted.open_age.
          order("coming desc, driver desc, first_name, surname").load
      end
      format.pdf do
        @participants = @group.participants.accepted.coming.drivers.
          order("first_name, surname").load

        output = DriverReport.new.add_data(@group, @participants).to_pdf
        
        render_pdf output, 'drivers'
      end
    end
  end
    
  # GET /admin/participants/tickets
  def tickets
    @ticketed = Participant.coming.accepted.ticketed.where('age > 5').count
    @ticketed_not_uploaded = Participant.coming.accepted.ticketed.where('age > 5').where('registration_nbr is null').count
    @to_be_ticketed = Participant.coming.accepted.to_be_ticketed.where('age > 5').count
    @ticket_updates = @participants = Participant.coming.accepted.ticket_updates.where('age > 5').count

    respond_to do |format|
      format.html # tickets.html.erb
    end
  end

  # POST /admin/participants/ticket_download
  def ticket_download
    @participants = Participant.coming.accepted.to_be_ticketed.where('age > 5').
      order('first_name, surname').load

    respond_to do |format|
      format.xlsx do
        render xlsx: "ticket_download", filename: "syg_tickets_#{Time.now.in_time_zone.strftime('%Y%m%d')}.xlsx"
        @participants.update_all(exported: true, dirty: false)
      end
    end
  end

  # POST /admin/participants/ticket_updates
  def ticket_updates
    @participants = Participant.coming.accepted.ticket_updates.where('age > 5').
      order('first_name, surname').load

    respond_to do |format|
      format.xlsx do
        render xlsx: "ticket_download", template: "admin/participants/ticket_download", filename: "syg_ticket_updates_#{Time.now.in_time_zone.strftime('%Y%m%d')}.xlsx"
        @participants.update_all(dirty: false)
      end
    end
  end

  # GET /admin/participants/ticket_full_extract
  def ticket_full_extract
    @participants = Participant.coming.accepted.where('age > 5').
      order('first_name, surname').load

    respond_to do |format|
      format.xlsx do
        render xlsx: "ticket_download", template: "admin/participants/ticket_download", filename: "syg_ticket_extract_#{Time.now.in_time_zone.strftime('%Y%m%d')}.xlsx"
      end
    end
  end

  # POST /admin/participants/ticket_reset
  def ticket_reset
    @participants = Participant.coming.accepted.ticketed.load

    respond_to do |format|
      format.html do 
        @participants.update_all(registration_nbr: nil, booking_nbr: nil, exported: false, dirty: false)

        @ticketed = Participant.coming.accepted.ticketed.where('age > 5').count
        @to_be_ticketed = Participant.coming.accepted.to_be_ticketed.where('age > 5').count
        @ticket_updates = @participants = Participant.coming.accepted.ticket_updates.where('age > 5').count

        render action: 'tickets'
      end
    end
  end

  # GET /admin/participants/participant_audit
  def participant_audit
    @participants = Participant.coming.accepted.
      order('surname, first_name').load

    respond_to do |format|
      format.xlsx { render xlsx: "participant_audit" }
    end
  end

  # GET /admin/participants/participant_integrity
  def participant_integrity
    @participants = Participant.coming.accepted.
      where('age = 0 or age is NULL').
      order('surname, first_name').load

    @user_integrity = User.participant_integrity_list

    respond_to do |format|
      format.html # tickets.html.erb
    end
  end

  # GET /admin/participants/day_visitors
  def day_visitors
    @group = Group.find_by_abbr('DAY')
    @participants = @group.participants.
      order('coming desc, first_name, surname').load

    respond_to do |format|
      format.html { @participants = @participants.paginate(page: params[:page], per_page: 100) }
      format.xlsx { render xlsx: "day_visitors" }
    end
  end
  
  # GET /admin/participants/1
  def show
  end

  # GET /admin/participants/new
  def new
    @participant.early_bird = @settings.early_bird

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/participants/new_day_visitor
  def new_day_visitor
    @participant = Participant.new
    @participant.coming_friday = false unless Time.now.friday?
    @participant.coming_saturday = false unless Time.now.saturday?
    @participant.coming_sunday = false unless Time.now.sunday?
    @participant.coming_monday = false unless Time.now.monday?

    respond_to do |format|
      format.html # new_day_visitor.html.erb
    end
  end

  # GET /admin/participants/1/edit
  def edit
    if @participant.date_of_birth.nil? && @participant.age
      @participant.date_of_birth = Date.today - @participant.age.years 
    elsif @participant.date_of_birth.nil?
      @participant.date_of_birth = Date.today - 30.years 
    end
  end

  # GET /admin/participants/1/edit_day_visitor
  def edit_day_visitor
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

  # POST /admin/participants/create_day_visitor
  def create_day_visitor
    @group = Group.find_by_abbr('DAY')
    @participant = Participant.new(day_visitor_params)
    @participant.spectator = true
    @participant.onsite = false
    @participant.group = @group
    @participant.dietary_requirements = "N/A"
    @participant.allergies = "N/A"
    @participant.email = 'changeme@example.com'

    if @participant.age < 18
      @participant.emergency_contact = 'Unknown'
      @participant.emergency_relationship = 'Unknown'
      @participant.emergency_phone_number = 'Unknown'
      @participant.emergency_email = 'changeme@example.com'
    end

    @participant.updated_by = current_user.id

    respond_to do |format|
        if @participant.save
            flash[:notice] = 'Day Visitor was successfully created.'
            format.html { render action: "edit_day_visitor" }
        else
            format.html { render action: "new_day_visitor" }
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

  # PATCH /admin/participants/1/update_day_visitor
  def update_day_visitor
    @participant = Participant.find(params[:id])
    @participant.updated_by = current_user.id

    respond_to do |format|
      if @participant.update(day_visitor_params)
        flash[:notice] = 'Day Visitor was successfully updated.'
        format.html { redirect_to day_visitors_admin_participants_url }
      else
        format.html { render action: "edit_day_visitor" }
      end
    end
  end

  # DELETE /admin/participants/1
  def destroy
    @participant.updated_by = current_user.id

    @participant.destroy

    respond_to do |format|
      format.html { redirect_to admin_participants_url }
    end
  end

  # DELETE /admin/participants/1/destroy_day_visitor
  def destroy_day_visitor
    @participant.updated_by = current_user.id

    @participant.destroy

    respond_to do |format|
      format.html { redirect_to day_visitors_admin_participants_url }
    end
  end

  # GET /admin/participants/new_import
  def new_import
    @participant = Participant.new
  end

  # POST /admin/participants/import
  def import
    if params[:participant] && params[:participant][:file].path =~ %r{\.xlsx$}i
      result = Participant.import_excel(params[:participant][:file], current_user)

      flash[:notice] = "Participants upload complete: #{result[:creates]} participants created; #{result[:updates]} updates; #{result[:errors]} errors"

      respond_to do |format|
        format.html { redirect_to admin_participants_url }
      end
    else
      flash[:notice] = "Upload file must be in '.xlsx' format"
      @participant = Participant.new

      respond_to do |format|
        format.html { render action: "new_import" }
      end
    end
  end

  # GET /admin/participants/new_ticket_import
  def new_ticket_import
    @participant = Participant.new
  end

  # POST /admin/participants/ticket_import
  def ticket_import
    if params[:participant] && params[:participant][:file].path =~ %r{\.xlsx$}i
      result = Participant.import_ticket_excel(params[:participant][:file], current_user)

      flash[:notice] = "Ticket upload complete: #{result[:updates]} updates; #{result[:misses]} participants not found; #{result[:day_visitors]} day visitors added; #{result[:errors]} errors"

      respond_to do |format|
        format.html { redirect_to tickets_admin_participants_url }
      end
    else
      flash[:notice] = "Upload file must be in '.xlsx' format"
      @participant = Participant.new

      respond_to do |format|
        format.html { render action: "new_ticket_import" }
      end
    end
  end

  # GET /admin/participants/1/new_voucher
  def new_voucher
  end

  # POST /admin/participants/1/add_voucher
  def add_voucher
    if params[:participant] && !params[:participant][:voucher_name].blank?
      name = (params[:participant][:voucher_name]).strip
      name.upcase!
      voucher = Voucher.find_by_name(name)

      if voucher && voucher.valid_for?(@participant)
        @participant.voucher = voucher
        @participant.save

        flash[:notice] = "Voucher added to participant"

        respond_to do |format|
          format.html { redirect_to edit_admin_participant_url(@participant) }
        end
      else
        flash[:notice] = "Voucher is not valid for this participant"

        respond_to do |format|
          format.html { render action: "new_voucher" }
        end
      end
    else
      flash[:notice] = "Voucher is not valid for this participant"

      respond_to do |format|
        format.html { render action: "new_voucher" }
      end
    end
  end

  # PATCH /admin/participants/1/delete_voucher
  def delete_voucher
    if @participant.voucher
      @participant.voucher_id = nil
      @participant.save
    
      flash[:notice] = "Voucher deleted"

      respond_to do |format|
        format.html { redirect_to edit_admin_participant_url(@participant) }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_admin_participant_url(@participant) }
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
      :date_of_birth,
      :gender,
      :coming_friday,
      :coming_saturday,
      :coming_sunday,
      :coming_monday,
      :address,
      :suburb,
      :postcode,
      :medicare_number,
      :medicare_expiry,
      :medical_injuries,
      :medical_info,
      :medications,
      :allergies,
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
      :licence_type,
      :number_plate,
      :early_bird,
      :email,
      :mobile_phone_number,
      :dietary_requirements,
      :emergency_contact,
      :emergency_relationship,
      :emergency_phone_number,
      :emergency_email,
      :amount_paid,
      :status,
      :wwcc_number,
      :driver_signature,
      :driver_signature_date
    )
  end

  def day_visitor_params
    params.require(:participant).permit(
      :first_name, 
      :surname,
      :coming,
      :age,
      :gender,
      :coming_friday,
      :coming_saturday,
      :coming_sunday,
      :coming_monday,
      :mobile_phone_number,
      :paid,
      :wwcc_number
    )
  end
end
