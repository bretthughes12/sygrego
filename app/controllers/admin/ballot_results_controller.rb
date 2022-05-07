class Admin::InfoController < ApplicationController
    before_action :authenticate_user!

    layout 'admin'

    # GET /admin/ballot_results
    # GET /admin/ballot_results?format=csv
    def index
        @ballot_results = BallotResult.all

        respond_to do |format|
            format.html # index.html.erb
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
