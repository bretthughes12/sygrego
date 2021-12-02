class Admin::ReportsController < ApplicationController
    before_action :authenticate_user!

    layout 'admin'

    # GET /admin/reports/finance_summary
    def finance_summary
        @finances = Participant.finances
    end
end
