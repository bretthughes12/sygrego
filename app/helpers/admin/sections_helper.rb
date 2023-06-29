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

    def finals_explanation(section)
        case
        when section.finals_format == "Top 2"
            "Grand-final only between top two teams."
        when section.finals_format == "Top 4"
            "Top four teams to play semi-finals: 1st vs 4th and 2nd vs 3rd."
        when section.finals_format == "Top 2 in Group"
            "Top two teams from each group to play cross-over semi-finals: 1st from Group 1 vs 2nd from Group 2 and 1st from Group 2 vs 2nd from Group 1."
        when section.finals_format == "Top in Group" && section.number_of_groups == 3
            "Top team in each group to play semi-finals, plus next best teams: 1st from Group 1 vs 1st from Group 3 and 1st from Group 2 vs next best team."
        else
            "Top team in each group to play semi-finals: 1st from Group 1 vs 1st from Group 3 and 1st from Group 2 1st from Group 4."
        end
    end
end
