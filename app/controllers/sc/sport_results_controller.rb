class Sc::SportResultsController < ApplicationController
    layout 'sc'
  
    # GET /sc/sport_results or /sc/sport_results.json
    def index
        @sections = Section.round_robin
    end
  
    # GET /sc/sport_results/1 or /sc/sport_results/1.json
    def show
        @results = SportResultEntry.where(section: params[:id])
        @section = Section.find_by_id(params[:id])
    end
end