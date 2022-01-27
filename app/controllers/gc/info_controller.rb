class Gc::InfoController < ApplicationController
    before_action :authenticate_user!
    before_action :find_group

    layout 'gc'

    # GET /gc/info/home
    def home
        @total_groups = Group.coming.count
        @total_participants = Participant.coming.count
        @participants_registered = @group.participants.coming.accepted.count

        render layout: @current_role.name
    end
end
