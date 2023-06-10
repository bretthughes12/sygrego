class Sc::SportResultsController < ApplicationController
    layout 'sc'
  
    # GET /sc/sport_results or /sc/sport_results.json
    def index
        @sections = Section.round_robin
    end
  
    # GET /sc/sport_results/1 or /sc/sport_results/1.json
    def show
        @sport_result_entries = SportResultEntry.where(section: params[:id]).order(:court, :match).load
        @section = Section.find_by_id(params[:id])
        @teams = @section.sport_entries
    end
end