class Gc::InfoController < GcController

    # GET /gc/info/home
    def home
        @total_groups = Group.not_admin.coming.count
        @total_participants = Participant.coming.accepted.count
        @participants_registered = @group.participants.coming.accepted.count
        @total_entries = @group.sport_entries.count
        @timelines = Timeline.current.order(:key_date, :name).limit(5).load

        render layout: @current_role.name
    end
end
