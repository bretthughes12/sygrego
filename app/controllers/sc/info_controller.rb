class Sc::InfoController < ScController
    before_action :authenticate_user!

    layout 'sc' 

    # GET /sc/info/home
    def home
        @total_groups = Group.coming.count
        @total_participants = Participant.accepted.coming.count
        @total_entries = SportEntry.count
        @total_volunteers = Volunteer.count
    end
end
