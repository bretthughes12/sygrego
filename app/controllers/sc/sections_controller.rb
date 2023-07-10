class Sc::SectionsController < ScController

  load_and_authorize_resource
  layout 'sc'

  # GET /sc/section
  def index
      @sections = Section.round_robin
  end
end  