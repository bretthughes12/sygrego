class Sc::SectionsController < ScController

  load_and_authorize_resource

  # GET /sc/section
  def index
    if params[:order] == 'session'
      @sections = Section.round_robin.incomplete.order(:session_id, :name).all
    elsif params[:filter] == 'none'
      @sections = Section.round_robin.order(:name).all
    else
      @sections = Section.round_robin.incomplete.order(:name).all
    end
  end
end  