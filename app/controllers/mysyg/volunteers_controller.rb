class Mysyg::VolunteersController < MysygController

    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'participant'
    
    def index
        @my_volunteers = @participant.volunteers
        @volunteers = @participant.available_volunteers
    end
  
    def edit
      @volunteer.participant_id = @participant.id
    end
  
    def update
      begin
        if @volunteer.update(volunteer_params)
          flash[:notice] = "Thanks for signing up!"
  
          redirect_to mysyg_volunteers_path(group: @group.mysyg_setting.mysyg_name)
        else
          render action: :edit
        end
  
      rescue ActiveRecord::StaleObjectError
        flash[:notice] = 'Somebody else has updated this volunteer.'
    
        redirect_to mysyg_volunteers_path(group: @group.mysyg_setting.mysyg_name)
      end
    end
    
  private
  
    def volunteer_params
      params.require(:volunteer).permit(:email, 
                                       :mobile_number,
                                       :t_shirt_size,
                                       :participant_id)
    end
  end
  