class Admin::ReportsController < ApplicationController
    before_action :authenticate_user!

    layout 'admin'

    # GET /admin/reports/finance_summary
    def finance_summary
        @finances = Participant.finances
    end

    # GET /admin/reports/service_preferences
    def service_preferences
        @sat_early = EventDetail.sat_early_service.sort
        @sat_late = EventDetail.sat_late_service.sort
        @sat_no_pref = EventDetail.sat_no_pref_service.sort
        @sun_early = EventDetail.sun_early_service.sort
        @sun_late = EventDetail.sun_late_service.sort
        @sun_no_pref = EventDetail.sun_no_pref_service.sort

        respond_to do |format|
            format.html { render layout: 'admin' }
            format.csv { render_csv "service_preferences" }
        end
    end
end
