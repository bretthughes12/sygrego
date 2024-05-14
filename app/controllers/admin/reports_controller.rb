class Admin::ReportsController < AdminController
    before_action :authenticate_user!

    # GET /admin/reports/finance_summary
    def finance_summary
        @finances = Participant.finances
    end

    # GET /admin/reports/service_preferences
    def service_preferences
        @total_groups = Group.coming.not_admin.count

        @sat_early = EventDetail.sat_early_service.sort
        @sat_late = EventDetail.sat_late_service.sort
        @sat_no_pref = EventDetail.sat_no_pref_service.sort
        @sun_early = EventDetail.sun_early_service.sort
        @sun_late = EventDetail.sun_late_service.sort
        @sun_no_pref = EventDetail.sun_no_pref_service.sort

        respond_to do |format|
            format.html { render layout: 'admin' }
            format.csv { render_csv "service_preferences" }
        end
    end

    # GET /participants/fees
    def fees
        @participants = []
        @participants << Participant.new
        @participants << Participant.new(early_bird: true)

        @participants << Participant.new(spectator: true)
        @participants << Participant.new(spectator: true, early_bird: true) 
        @participants << Participant.new(onsite: true, rego_type: "Part Time", coming_friday: false, coming_sunday: false, coming_monday: false)
        @participants << Participant.new(onsite: true, rego_type: "Part Time", coming_friday: false, coming_sunday: false, coming_monday: false, spectator: true)
        @participants << Participant.new(onsite: false, spectator: true, rego_type: "Part Time", coming_friday: false, coming_sunday: false, coming_monday: false)
        @participants << Participant.new(helper: true, spectator: true)
        @participants << Participant.new(onsite: false, helper: true, spectator: true)
        @participants << Participant.new(group_coord: true)
        @participants << Participant.new(group_coord: true, spectator: true)

        p = Participant.new
        p.guest = true
        @participants << p

        p = Participant.new(spectator: true)
        p.guest = true
        @participants << p

        @participants << Participant.new(age: 11, spectator: true, emergency_contact: "Elvis", emergency_relationship: "Idol", emergency_phone_number: "9555-5555")
        @participants << Participant.new(age: 5, emergency_contact: "Elvis", emergency_relationship: "Idol", emergency_phone_number: "9555-5555")

        respond_to do |format|
            format.html 
        end
    end

    # GET /admin/reports/gender_summary
    def gender_summary
        @groups = Group.coming.not_admin.order(:abbr).load
    end

    # GET /admin/reports/sport_integrity
    def sport_integrity
        @sections_wo_sc = Section.without_sc
        @sections_too_many = Section.too_many_entries_same_group
        @section_conflicts = Volunteer.section_conflicts
    end
end
