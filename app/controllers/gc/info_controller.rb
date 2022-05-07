class Gc::InfoController < ApplicationController
    before_action :authenticate_user!
    before_action :find_group

    layout 'gc'

    # GET /gc/info/home
    def home
        # authorise a detail that a GC or Church Rep role has access to
        authorize! :edit, @group.event_detail

        @total_groups = Group.coming.count
        @total_participants = Participant.coming.count
        @participants_registered = @group.participants.coming.accepted.count
        @total_entries = @group.sport_entries.count

        render layout: @current_role.name
    end
end
