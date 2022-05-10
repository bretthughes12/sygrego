module Admin::SportEntriesHelper
    def sport_entry_display_class(sport_entry)
        case
        when sport_entry.status == 'Requested'
            "table-warning"
        when sport_entry.status == 'Entered'
            "table-primary"
        when sport_entry.status == 'To Be Confirmed'
            "table-danger"
        else
            "table-dark"
        end
    end

    def should_show_draw_link(entry)
        entry.section && entry.section.draw_file.attached?
    end
    
    def should_show_delete_link(entry)
        @current_user.role?(:admin)|| 
          !draw_complete(entry) ||
          entry.grade.status == "Open" ||
          entry.status == "Waiting List"
    end
    
    def should_show_confirm_button(entry)
        entry.status == "To Be Confirmed"
    end

#    def clash_status(sports)
#        if sports.uniq.size > 1
#          "list-line-clash"
#        end
#    end
    
    def draw_complete(entry)
        if entry.grade.sport.classification == "Team"
            @settings.team_draws_complete
        else
            @settings.indiv_draws_complete
        end
    end

    def sport_entry_status_tooltip(entry)
        case 
        when entry.status == "Requested"
            "This sport grade has limited availability. This entry is 'requested' until restricted sports are allocated"
        when entry.status == "Entered"
            "You have been entered into this sport grade"
        when entry.status == "To Be Confirmed"
            "You must confirm your entry in this sport grade"
        else
            "You are on the waiting list for this sport grade, in case another team withdraws"
        end
    end
end
