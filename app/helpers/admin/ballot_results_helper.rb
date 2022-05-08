module Admin::BallotResultsHelper
    def group_ballot_display_class(result)
        group[:new_group] ? 'table-warning' : 'table-primary'
    end
end
