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
end
