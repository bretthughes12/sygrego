class Admin::SportResultsController < ApplicationController
    layout 'admin'
  
    # GET /admin/sport_results or /admin/sport_results.json
    def index
        @sections = Section.round_robin
    end
  
    # GET /admin/sport_results/1 or /admin/sport_results/1.json
    def show
        @results = SportResultEntry.where(section: params[:id]).order(:court, :match).load
        @section = Section.find_by_id(params[:id])

        respond_to do |format|
            format.html # show.html.erb
            format.csv  { render_csv "results_#{@section.id}", "results" }
        end
    end
  
    private
    # Only allow a list of trusted parameters through.
    def admin_sport_result_params
        params.fetch(:id, {})
    end
end