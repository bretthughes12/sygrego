class ChartsController < ApplicationController
    def admin_groups
        @total_groups = Group.coming.count
        new_groups = Group.coming.not_admin.new_group.count
        last_year_groups = Group.coming.not_admin.last_year.count
        admin_groups = Group.coming.is_admin.count

        groups_data = []
        groups_data << ["New groups", new_groups]
        groups_data << ["Came last time", last_year_groups]
        groups_data << ["Returning groups", @total_groups - new_groups - last_year_groups - admin_groups]
        groups_data << ["Admin", admin_groups]

        render json: groups_data
    end

    def admin_participants
        @total_participants = Participant.accepted.coming.count

        participants_data = []
        participants_data << ["Spectators", Participant.coming.accepted.spectators.count]
        participants_data << ["Playing sport", Participant.coming.accepted.playing_sport.count]
        participants_data << ["Not approved", Participant.coming.requiring_approval.count]

        render json: participants_data
    end

    def admin_sport_entries
        @total_entries = SportEntry.count

        entries_data = []
        entries_data << ["Entered", SportEntry.entered.count]
        entries_data << ["To Be Confirmed", SportEntry.to_be_confirmed.count]
        entries_data << ["Requested", SportEntry.requested.count]
        entries_data << ["Waiting List", SportEntry.waiting_list.count]
    
        render json: entries_data
    end

    def admin_volunteers
        @total_volunteers = Volunteer.count

        volunteers_data = []
        volunteers_data << ["Filled", Volunteer.filled.count]
        volunteers_data << ["Vacant", Volunteer.unfilled.count]

        render json: volunteers_data
    end

    def admin_group_stats
        group_data = Statistic.order(:year).group(:year).group('20 - weeks_to_syg').sum(:number_of_groups).chart_json

        render json: group_data
    end

    def admin_participant_stats
        participant_data = Statistic.order(:year).group(:year).group('20 - weeks_to_syg').sum(:number_of_participants).chart_json
        render json: participant_data
    end

    def admin_sport_entry_stats
        sport_data = Statistic.order(:year).group(:year).group('20 - weeks_to_syg').sum(:number_of_sport_entries).chart_json

        render json: sport_data
    end

    def admin_volunteer_stats
        volunteer_data = Statistic.order(:year).group(:year).group('20 - weeks_to_syg').sum(:number_of_volunteer_vacancies).chart_json

        render json: volunteer_data
    end

    def gc_participants
        find_group

        participants_data = []
        participants_data << ["Spectators", @group.participants.coming.accepted.spectators.count]
        participants_data << ["Playing sport", @group.participants.coming.accepted.playing_sport.count]
        participants_data << ["Not approved", @group.participants.coming.requiring_approval.count]

        render json: participants_data
    end

    def gc_sport_entries
        find_group

        @total_entries = @group.sport_entries.count

        entries_data = []
        entries_data << ["Entered", @group.sport_entries.entered.count]
        entries_data << ["To Be Confirmed", @group.sport_entries.to_be_confirmed.count]
        entries_data << ["Requested", @group.sport_entries.requested.count]
        entries_data << ["Waiting List", @group.sport_entries.waiting_list.count]
    
        render json: entries_data
    end

    def evening_saturday_preferences
        @total_groups = Group.coming.not_admin.count
    
        early = Group.coming.not_admin.sat_early_service.count
        late = Group.coming.not_admin.sat_late_service.count
        no_pref = @total_groups - early - late
    
        service_data = []
        service_data << ["Early session", early]
        service_data << ["Late session", late]
        service_data << ["No preference", no_pref]
    
        render json: service_data
    end

    def evening_sunday_preferences
        @total_groups = Group.coming.not_admin.count
    
        early = Group.coming.not_admin.sun_early_service.count
        late = Group.coming.not_admin.sun_late_service.count
        no_pref = @total_groups - early - late
    
        service_data = []
        service_data << ["Early session", early]
        service_data << ["Late session", late]
        service_data << ["No preference", no_pref]
    
        render json: service_data
    end
end