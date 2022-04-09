module Admin::VolunteerHelper
    def should_display_t_shirt_flag
        @volunteer.volunteer_type && @volunteer.t_shirt
    end
end