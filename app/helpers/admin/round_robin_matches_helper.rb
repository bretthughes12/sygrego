module Admin::RoundRobinMatchesHelper
    def forfeit_display_class(forfeit)
        case
        when forfeit 
            "table-danger"
        else
            "table-dark"
        end
    end
end
