class Mysyg::ParticipantsController < MysygController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'participant'
    
    # GET /mysyg/:group/participants/1/edit
    def edit
    end
  
    # GET /mysyg/:group/drivers
    def drivers
    end
  
    # GET /mysyg/:group/notes
    def notes
    end
  
    # PATCH /mysyg/:group/participants/1
    def update
      respond_to do |format|
        if @participant.update(participant_params)
          flash[:notice] = 'Details successfully updated.'
          format.html { redirect_to home_url(current_user) }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # PATCH /mysyg/:group/participants/1/update_drivers
    def update_drivers
      respond_to do |format|
        if @participant.update(participant_driving_params)
          if @participant.driver_signature 
            @participant.driver_signature_date = Time.now
            @participant.save
          end
          flash[:notice] = 'Details successfully updated.'
          format.html { redirect_to root_url(current_user) }
        else
          format.html do
            flash[:notice] = 'Update failed. See below for the reasons.'
            render action: "drivers"
          end
        end
      end
    end
  
    # PATCH /mysyg/:group/participants/1/update_notes
    def update_notes
      respond_to do |format|
        if @participant.update(participant_notes_params)
          flash[:notice] = 'Details successfully updated.'
          format.html { redirect_to root_url(current_user) }
        else
          format.html do
            flash[:notice] = 'Update failed. See below for the reasons.'
            render action: "edit_notes"
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
        :driving_to_syg,
        :licence_type,
        :number_plate,
        :driver_signature
      )
    end
    
    def participant_notes_params
      params.require(:participant).permit( 
        :lock_version,
        :camping_preferences,
        :sport_notes
      )
    end
end
