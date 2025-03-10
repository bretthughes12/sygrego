class Gc::SportPreferencesController < GcController
    load_and_authorize_resource
  
    # GET gc/groups/1/sport_preferences
    def index
      respond_to do |format|
        format.html do
          if session[:sport_pref_filter].nil?
            session[:sport_pref_filter] = {entered: true, in_sport: true}
          end
      
          options = {}
          [:entered, :in_sport].each do |o|
            case 
              when params[o]
                options[o] = session[:sport_pref_filter][o] = true 
      
              when params[:commit]
                options[o] = session[:sport_pref_filter][o] = false
      
              when session[:sport_pref_filter][o]
                options[o] = session[:sport_pref_filter][o] 
      
              else
                options[o] = session[:sport_pref_filter][o] = false
            end
          end
          
          @entered = session[:sport_pref_filter][:entered]
          @in_sport = session[:sport_pref_filter][:in_sport]
      
          @sport_preferences = SportPreference.locate_for_group(@group, options)
        end
        format.xlsx do 
          @sport_preferences = SportPreference.locate_for_group(@group, {entered: true, in_sport: true})
          render xlsx: "sport_prefs", template: "gc/sport_preferences/sport_prefs", filename: "sport_preferences.xlsx" 
        end
      end
    end
  
    # POST gc/sport_preferences/1/add_to_sport_entry
    def add_to_sport_entry
      @sport_preference = SportPreference.find(params[:id])
      sport_entry = @sport_preference.available_sport_entry
      participant = @sport_preference.participant

      sport_entry.participants << @sport_preference.participant if participant.available_sport_entries.include?(sport_entry)
      flash[:notice] = "Participant added to sport entry"
  
      respond_to do |format|
        format.html { redirect_to gc_sport_preferences_path } 
      end
    end
  
    # POST gc/sport_preferences/1/create_sport_entry
    # def create_sport_entry
    #   @sport_preference = SportPreference.find(params[:id])
  
    #   sport_entry = SportEntry.new
    #   sport_entry.group = @group
    #   sport_entry.grade = @sport_preference.grade
    #   sport_entry.status = sport_entry.grade.starting_status
    #   sport_entry.section = sport_entry.grade.starting_section
  
    #   sport_entry.participants << @sport_preference.participant
  
    #   if sport_entry.save
    #     flash[:notice] = "New sport entry created"
    #   else
    #     flash[:notice] = "There was a problem creating the sport entry"
    #   end
  
    #   respond_to do |format|
    #     format.html { redirect_to gc_sport_preferences_path } 
    #   end
    # end
  
    # DELETE gc/sport_preferences/1/remove_from_sport_entry
    def remove_from_sport_entry
      @sport_preference = SportPreference.find(params[:id])
      sport_entry = @sport_preference.sport_entry
      
      sport_entry.participants.destroy(@sport_preference.participant)
      flash[:notice] = "Participant removed from sport entry"
  
      respond_to do |format|
        format.html { redirect_to gc_sport_preferences_path } 
      end
    end
end
  