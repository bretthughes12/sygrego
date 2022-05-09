module Admin::BallotResultsHelper
    def group_ballot_display_class(result)
        result[:new_group] ? 'table-warning' : 'table-primary'
    end
end
