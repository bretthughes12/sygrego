class ChartsController < ApplicationController
    def admin_groups
        total_groups = Group.coming.count
        new_groups = Group.coming.not_admin.new_group.count
        last_year_groups = Group.coming.not_admin.last_year.count
        admin_groups = Group.coming.is_admin.count

        groups_data = []
        groups_data << ["New groups", new_groups]
        groups_data << ["Came " + (@settings.this_year - 1).to_s, last_year_groups]
        groups_data << ["Came pre-" + (@settings.this_year - 1).to_s, total_groups - new_groups - last_year_groups - admin_groups]
        groups_data << ["Admin", admin_groups]

        render json: groups_data
    end

    def admin_participants
        participants_data = []
        participants_data << ["Spectators", Participant.coming.accepted.spectators.count]
        participants_data << ["Playing", Participant.coming.accepted.playing_sport.count]
        participants_data << ["Not Approved", Participant.coming.requiring_approval.count]

        render json: participants_data
    end

    def gc_participants
        find_group

        participants_data = []
        participants_data << ["Spectators", @group.participants.coming.accepted.spectators.count]
        participants_data << ["Playing", @group.participants.coming.accepted.playing_sport.count]
        participants_data << ["Not Approved", @group.participants.coming.requiring_approval.count]

        render json: participants_data
    end
end