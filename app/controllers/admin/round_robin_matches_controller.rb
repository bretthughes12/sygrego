class Admin::RoundRobinMatchesController < ApplicationController

  load_and_authorize_resource 
  before_action :authenticate_user!
  
  layout "admin"

  # GET /admin/sections/1/round_robin_mmatches
  def index
    @section = Section.find_by_id(params[:section_id])
    @round_robin_matches = RoundRobinMatch.where(section: @section.id).order(:match).load

    respond_to do |format|
      format.html # index.html.erb
      format.csv  { render_csv "results_#{@section.name}", "results" }
    end
  end

  # GET /admin/round_robin_matches/new_import
  def new_import
    @round_robin_match = RoundRobinMatch.new
  end
  
  # POST /admin/round_robin_matches/import
  def import
    if params[:round_robin_match] && params[:round_robin_match][:file].path =~ %r{\.csv$}i
      result = RoundRobinMatch.import(params[:round_robin_match][:file], current_user)

      flash[:notice] = "Round Robin Draws upload complete: #{result[:creates]} matches created; #{result[:updates]} updates; #{result[:errors]} errors"

      respond_to do |format|
        format.html { redirect_to results_admin_sections_url }
      end
    else
      flash[:notice] = "Upload file must be in '.csv' format"
      @round_robin_match = RoundRobinMatch.new

      respond_to do |format|
        format.html { render action: "new_import" }
      end
    end
  end
end