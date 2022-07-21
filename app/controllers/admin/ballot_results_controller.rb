class Admin::BallotResultsController < ApplicationController
    before_action :authenticate_user!

    layout 'admin'

    # GET /admin/ballot_results
    # GET /admin/ballot_results?format=csv
    def index
        @ballot_results = BallotResult.order(:sport_name, :grade_name, :sport_entry_status, :section_name, :group_name).all

        respond_to do |format|
            format.csv  { render_csv "restricted_sports_allocation" }
        end
    end

    # GET /ballot_results/summary
    def summary
        @group_results = BallotResult.summary

        respond_to do |format|
            format.html # summary.html.erb
        end
    end
end
