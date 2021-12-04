class Gc::InfoController < ApplicationController
    before_action :authenticate_user!
    before_action :find_group

    layout 'gc'

    # GET /gc/info/home
    def home
        @total_groups = Group.coming.count
        @total_participants = Participant.coming.count
        @participants_registered = @group.participants.coming.accepted.count

        @participants_data = []
        @participants_data << ChartData.new("Spectators", @group.participants.coming.accepted.spectators.count)
        @participants_data << ChartData.new("Playing", @group.participants.coming.accepted.playing_sport.count)
        @participants_data << ChartData.new("Not Approved", @group.participants.requiring_approval.count)
    end
end
