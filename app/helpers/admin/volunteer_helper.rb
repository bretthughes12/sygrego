module Admin::VolunteerHelper
    def sport_coord_display_class(volunteer)
        case
        when volunteer.returned
            "table-primary"
        when volunteer.collected
            "table-warning"
        else
            "table-dark"
        end
    end
    
    def should_display_t_shirt_flag
        @volunteer.volunteer_type && @volunteer.t_shirt
    end
end