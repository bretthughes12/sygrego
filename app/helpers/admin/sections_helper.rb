module Admin::SectionsHelper
    def results_display_class(section)
        case
        when section.submitted?
            "table-primary"
        when section.started?
            "table-danger"
        else
            "table-warning"
        end
    end
end
