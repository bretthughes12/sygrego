class Sc::SectionsController < ScController

  load_and_authorize_resource

  # GET /sc/section
  def index
      @sections = Section.round_robin.order(:name).all
  end
end  