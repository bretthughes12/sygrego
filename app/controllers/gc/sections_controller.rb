class Gc::SectionsController < GcController
    load_and_authorize_resource
  
    # GET /gc/sections
    def index
      @sections = Section.active.includes(:session, :venue).
        order(:name).load
      
      respond_to do |format|
        format.xlsx { render xlsx: "index", filename: "sports_timetable.xlsx" }
      end
    end
end
