class Mysyg::SportPreferencesController < MysygController

    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'participant'
  
    # GET mysyg/:group/sports
    def index
      @sport_preferences = SportPreference.prepare_for_participant(@participant)
    end
  
    # PUT mysyg/:group/sport_preferences/update_multiple?session=1
    def update_multiple
      params[:sport_preferences].keys.each do |id|
        preference = SportPreference.find(id.to_i)
        preference.update(sport_preference_params(id))
      end
      flash[:notice] = "Preferences updated"
      redirect_to mysyg_sports_path
    end
  
  private
  
    def sport_preference_params(id)
      params.require(:sport_preferences)
            .fetch(id)
            .permit(:grade_id, 
                    :preference)
    end
  end
  