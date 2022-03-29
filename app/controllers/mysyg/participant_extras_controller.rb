class Mysyg::ParticipantExtrasController < MysygController

    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'participant'
  
    # GET mysyg/:group/extras
    def index
      @participant_extras = ParticipantExtra.initialise_for_participant(@participant)
    end
  
    # PATCH mysyg/:group/extras/update_multiple
    def update_multiple
      @participant_extras = []
      
      params[:participant_extras].keys.each do |id|
        pe = ParticipantExtra.find(id.to_i)
        pe.update(participant_extra_params(id))
        @participant_extras << pe unless pe.errors.empty?
      end
  
      if @participant_extras.empty?
        flash[:notice] = "Updated"
        redirect_to mysyg_extras_path
      else
        render :action => "index"  
      end
    end
  
  private
  
    def participant_extra_params(id)
      params.require(:participant_extras)
            .fetch(id)
            .permit(:wanted,
                    :size,
                    :comment)
    end
  end
  