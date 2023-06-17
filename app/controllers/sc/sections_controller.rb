class Sc::SectionsController < ApplicationController

  load_and_authorize_resource
  layout 'sc'

  # GET /sc/sectiona 
  def index
      @sections = Section.round_robin
  end

  # GET /sc/sections/1 
  def show
      @sport_result_entries = SportResultEntry.where(section: @section).order(:court, :match).load
      @teams = @section.sport_entries
  end
end  