module Admin::AwardsHelper
    def award_display_class(award)
        case
        when award.flagged
            "table-primary"
        else
            "table-secondary"
        end
    end
end
