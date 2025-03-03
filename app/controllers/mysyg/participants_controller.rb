class Mysyg::ParticipantsController < MysygController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'participant'
    
    # GET /mysyg/:group/participants/1/edit
    def edit
      if @participant.date_of_birth.nil? && @participant.age
        @participant.date_of_birth = Date.today - @participant.age.years 
      elsif @participant.date_of_birth.nil?
        @participant.date_of_birth = Date.today - 30.years 
      end

      @start_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.beginning.order(:order_number))
      @personal_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.personal.order(:order_number))
      @medical_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.medical.order(:order_number))
    end
  
    # GET /mysyg/:group/drivers
    def drivers
      @driving_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.driving.order(:order_number))
    end
  
    # GET /mysyg/:group/edit_camping
    def edit_camping
      @camping_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.camping.order(:order_number))
    end
  
    # GET /mysyg/:group/edit_sports
    def edit_sports
      @sports_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.sports.order(:order_number))
    end
  
    # PATCH /mysyg/:group/participants/1
    def update
      respond_to do |format|
        @participant.load_custom_answers(params[:participant]) 

        if @participant.update(participant_params)
          QuestionResponse.save_responses(@participant, params[:participant])

          flash[:notice] = 'Details successfully updated.'
          format.html { redirect_to home_url(current_user) }
        else
          format.html do
            @start_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.beginning.order(:order_number))
            @personal_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.personal.order(:order_number))
            @medical_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.medical.order(:order_number))
                  
            render action: "edit"
          end
        end
      end
    end
  
    # PATCH /mysyg/:group/participants/1/update_drivers
    def update_drivers
      @participant.load_custom_answers(params[:participant]) 

      respond_to do |format|
        if @participant.update(participant_driving_params)
          QuestionResponse.save_responses(@participant, params[:participant])

          if @participant.driver_signature 
            @participant.driver_signature_date = Time.now
            @participant.save
          end
          flash[:notice] = 'Details successfully updated.'
          format.html { redirect_to home_url(current_user) }
        else
          format.html do
            @driving_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.driving.order(:order_number))

            flash[:notice] = 'Update failed. See below for the reasons.'
            render action: "drivers"
          end
        end
      end
    end
  
    # PATCH /mysyg/:group/participants/1/update_camping
    def update_camping
      @participant.load_custom_answers(params[:participant]) 

      respond_to do |format|
        if @participant.update(participant_camping_params)
          QuestionResponse.save_responses(@participant, params[:participant])

          flash[:notice] = 'Details successfully updated.'
          format.html { redirect_to home_url(current_user) }
        else
          format.html do
            @camping_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.camping.order(:order_number))

            flash[:notice] = 'Update failed. See below for the reasons.'
            render action: "edit_camping"
          end
        end
      end
    end
  
    # PATCH /mysyg/:group/participants/1/update_sports
    def update_sports
      @participant.load_custom_answers(params[:participant]) 

      respond_to do |format|
        if @participant.update(participant_sports_params)
          QuestionResponse.save_responses(@participant, params[:participant])

          flash[:notice] = 'Details successfully updated.'
          format.html { redirect_to home_url(current_user) }
        else
          format.html do
            @sports_answers = QuestionResponse.find_or_create_responses(@participant, @group.questions.sports.order(:order_number))

            flash[:notice] = 'Update failed. See below for the reasons.'
            render action: "edit_sports"
          end
        end
      end
    end
  
    # POST /mysyg/:group/participants/1/add_voucher
    def add_voucher
      if params[:participant] && !params[:participant][:voucher_name].blank?
        name = (params[:participant][:voucher_name]).strip
        name.upcase!
        voucher = Voucher.find_by_name(name)

        if voucher && voucher.valid_for?(@participant)
          @participant.voucher = voucher
          @participant.save

          flash[:notice] = "Voucher added"

          respond_to do |format|
            format.html { redirect_to edit_mysyg_participant_path(group: @group.mysyg_setting.mysyg_name, id: @participant.id) }
          end
        else
          flash[:notice] = "Invalid voucher"

          respond_to do |format|
            format.html { render action: "new_voucher" }
          end
        end
      else
        flash[:notice] = "Invalid voucher"

        respond_to do |format|
          format.html { render action: "new_voucher" }
        end
      end
    end
  
    # PATCH /mysyg/:group/participants/1/delete_voucher
    def delete_voucher
      if @participant.voucher
        @participant.voucher_id = nil
        @participant.save
      
        flash[:notice] = "Voucher deleted"

        respond_to do |format|
          format.html { redirect_to edit_mysyg_participant_path(group: @group.mysyg_setting.mysyg_name, id: @participant.id) }
        end
      else
        respond_to do |format|
          format.html { redirect_to edit_mysyg_participant_path(group: @group.mysyg_setting.mysyg_name, id: @participant.id) }
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
        :group_fee_category_id,
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
        :email,
        :mobile_phone_number,
        :dietary_requirements,
        :emergency_contact,
        :emergency_relationship,
        :emergency_phone_number,
        :emergency_email,
        :wwcc_number,
        :driver_signature,
        :driver_signature_date
      )
    end
    
    def participant_driving_params
      params.require(:participant).permit( 
        :lock_version,
        :driver,
        :licence_type,
        :number_plate,
        :driver_signature
      )
    end
    
    def participant_camping_params
      params.require(:participant).permit( 
        :lock_version
      )
    end
    
    def participant_sports_params
      params.require(:participant).permit( 
        :lock_version
      )
    end
end
