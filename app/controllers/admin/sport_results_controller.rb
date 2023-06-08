class Admin::SportResultsController < ApplicationController
    layout 'admin'
  
    # GET /admin/sport_results or /admin/sport_results.json
    def index
        @sections = Section.all
    end
  
    # GET /admin/sport_results/1 or /admin/sport_results/1.json
    def show
        @results = SportResultEntry.where(section: params[:id])
        @section = Section.find_by_id(params[:id])
    end
  
    private
    # Only allow a list of trusted parameters through.
    def admin_sport_result_params
        params.fetch(:id, {})
    end
end