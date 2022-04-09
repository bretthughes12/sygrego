class Mysyg::InfoController < MysygController

    layout 'participant'
  
    # GET /mysyg/:group/home
    def home
      @total_groups = Group.coming.count
      @total_participants = Participant.coming.accepted.count
  
      respond_to do |format|
        format.html # home.html.erb
      end
    end
  
#    # GET /mysyg/:group/camping
#    def camping
#      respond_to do |format|
#        format.html 
#      end
#    end
  
    # GET /mysyg/:group/finance
    def finance
      @fee = @participant.group_fee
      @total_owing = @participant.total_owing
      ParticipantExtra.initialise_for_participant(@participant)
      @extras = @participant.participant_extras.wanted.load
      
      respond_to do |format|
        format.html 
      end
    end
  end
  