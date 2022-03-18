class Mysyg::ParticipantsController < MysygController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'participant'
    
    # GET /mysyg/:group/participants/1/edit
    def edit
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
        :email,
        :mobile_phone_number,
        :dietary_requirements,
        :emergency_contact,
        :emergency_relationship,
        :emergency_phone_number,
        :wwcc_number,
        :driver_signature,
        :driver_signature_date
      )
    end
end
