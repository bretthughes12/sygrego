class Gc::ParticipantsController < GcController
    load_and_authorize_resource
  
    # GET /gc/participants
    def index
      @participants = @group.participants.accepted.
        order('coming desc, first_name, surname').load
  
      respond_to do |format|
        format.html do
          @participants = @participants.paginate(page: params[:page], per_page: 100)
          render layout: @current_role.name
        end
        format.xlsx { render xlsx: "index", filename: "participants.xlsx" }
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
        format.xlsx do 
          @participants = @group.participants.accepted.coming.drivers.
            order("first_name, surname").load

          render xlsx: "drivers", filename: "drivers.xlsx"
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
        format.xlsx do 
          @participants = @group.participants.coming.accepted.
            open_age.order("coming desc, first_name, surname").load

          render xlsx: "wwccs", filename: "wwccs.xlsx"
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
        format.xlsx do 
          render xlsx: "participant_fees", filename: "participant_fees.xlsx"
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
        format.xlsx { render xlsx: "sports_plan", filename: "sports_plan.xlsx" }
      end
    end
    
    # GET /gc/participants/camping_preferences
    def camping_preferences
      @participants = @group.participants.accepted.coming.
        order("first_name, surname").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
        format.xlsx { render xlsx: "camping_preferences", filename: "camping_preferences.xlsx" }
      end
    end
    
    # GET /gc/participants/sport_notes
    def sport_notes
      @participants = @group.participants.accepted.coming.
        order("first_name, surname").load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
        format.xlsx { render xlsx: "sport_notes", filename: "sport_notes.xlsx" }
      end
    end
    
    # GET /gc/participants/1
    def show
      render layout: @current_role.name
    end
  
    # GET /gc/participants/new
    def new
      @start_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.beginning.order(:order_number))
      @personal_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.personal.order(:order_number))
      @medical_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.medical.order(:order_number))
      @disclaimer_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.disclaimer.order(:order_number))

      @participant.date_of_birth = Date.today - 30.years

      respond_to do |format|
        format.html { render layout: @current_role.name }
      end
    end
  
    # GET /gc/participants/1/edit
    def edit
      if @participant.date_of_birth.nil? && @participant.age
        @participant.date_of_birth = Date.today - @participant.age.years 
      elsif @participant.date_of_birth.nil?
        @participant.date_of_birth = Date.today - 30.years 
      end

      @start_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.beginning.order(:order_number))
      @personal_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.personal.order(:order_number))
      @medical_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.medical.order(:order_number))
      @disclaimer_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.disclaimer.order(:order_number))

      render layout: @current_role.name
    end
  
    # GET /gc/participants/1/edit_driver
    def edit_driver
      @driving_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.driving.order(:order_number))

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
  
    # GET /gc/participants/1/edit_camping_preferences
    def edit_camping_preferences
      @camping_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.camping.order(:order_number))

      render layout: @current_role.name
    end
  
    # GET /gc/participants/1/edit_sport_notes
    def edit_sport_notes
      @sports_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.sports.order(:order_number))

      render layout: @current_role.name
    end
  
    # GET /gc/participants/1/edit_sports
    def edit_sports
      @grades = @participant.available_grades
      @sections = @participant.available_sections
      @sport_entry = SportEntry.new

      render layout: @current_role.name
    end
  
    # GET /gc/participants/1/edit_transfer
    def edit_transfer
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
          QuestionResponse.save_responses(@participant, params[:participant])

          @start_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.beginning.order(:order_number))
          @personal_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.personal.order(:order_number))
          @medical_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.medical.order(:order_number))
          @disclaimer_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.disclaimer.order(:order_number))

          flash[:notice] = 'Participant was successfully created.'
          format.html { render action: "edit", layout: @current_role.name }
        else
          @start_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.beginning.order(:order_number))
          @personal_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.personal.order(:order_number))
          @medical_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.medical.order(:order_number))
          @disclaimer_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.disclaimer.order(:order_number))

          format.html { render action: "new", layout: @current_role.name }
        end
      end
    end

    # PATCH /gc/participants/1
    def update
      @participant.load_custom_answers(params[:participant]) 
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_params)
          QuestionResponse.save_responses(@participant, params[:participant])

          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to gc_participants_url }
        else
          format.html do
            @start_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.beginning.order(:order_number))
            @personal_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.personal.order(:order_number))
            @medical_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.medical.order(:order_number))
            @disclaimer_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.disclaimer.order(:order_number))

            render action: "edit", layout: @current_role.name
          end
        end
      end
    end

    # PATCH /gc/participants/1/update_driver
    def update_driver
      @participant.load_custom_answers(params[:participant]) 
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_driver_params)
          QuestionResponse.save_responses(@participant, params[:participant])

          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to drivers_gc_participants_url }
        else
          format.html do 
            @driving_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.driving.order(:order_number))
    
            render action: "edit_driver", layout: @current_role.name
          end
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

    # PATCH /gc/participants/1/update_camping_preferences
    def update_camping_preferences
      @participant.load_custom_answers(params[:participant]) 
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_camping_preferences_params)
          QuestionResponse.save_responses(@participant, params[:participant])

          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to camping_preferences_gc_participants_url }
        else
          format.html do 
            @camping_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.camping.order(:order_number))

            render action: "edit_camping_preferences", layout: @current_role.name
          end
        end
      end
    end

    # PATCH /gc/participants/1/update_sport_notes
    def update_sport_notes
      @participant.load_custom_answers(params[:participant]) 
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_sport_notes_params)
          QuestionResponse.save_responses(@participant, params[:participant])

          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to sport_notes_gc_participants_url }
        else
          format.html do 
            @sports_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.sports.order(:order_number))

            render action: "edit_sport_notes", layout: @current_role.name
          end
        end
      end
    end

    # PATCH /gc/participants/1/update_transfer
    def update_transfer
      @participant.updated_by = current_user.id

      respond_to do |format|
        if @participant.update(participant_transfer_params)
          @participant.status = 'Transfer pending'
          raw, hashed = Devise.token_generator.generate(Participant, :transfer_token)
          @participant.transfer_token = hashed
          @participant.save

          ParticipantMailer.transfer(@participant, hashed).deliver_now

          flash[:notice] = 'Participant transferred.'
          format.html { redirect_to gc_participants_url }
        else
          format.html { render action: "edit_transfer", layout: @current_role.name }
        end
      end
    end

    # PATCH /gc/participants/1/accept
    def accept
      @participant.updated_by = current_user.id
      @participant.accept!
      user = @participant.users.first
      token = user.get_reset_password_token if user

      respond_to do |format|
        flash[:notice] = 'Participant was accepted into your group.'
        UserMailer.accept_participant(@participant, @group, token).deliver_now if token
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
        name = (params[:participant][:voucher_name]).strip
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
        :email,
        :mobile_phone_number,
        :dietary_requirements,
        :emergency_contact,
        :emergency_relationship,
        :emergency_phone_number,
        :emergency_email,
        :amount_paid,
        :wwcc_number
      )
    end

    def participant_driver_params
      params.require(:participant).permit(
        :lock_version,
        :driver,
        :licence_type,
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
        :group_fee_category_id,
        :amount_paid
      )
    end
  
    def participant_camping_preferences_params
      params.require(:participant).permit(
        :lock_version
      )
    end
  
    def participant_sport_notes_params
      params.require(:participant).permit(
        :lock_version
      )
    end
  
    def participant_transfer_params
      params.require(:participant).permit(
        :lock_version,
        :transfer_email
      )
    end
end
