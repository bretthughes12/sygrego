class Api::SectionsController < ApiController
    
    # GET /api/sections/1.xml
    def show
      @section = Section.find(params[:id])
      
      respond_to do |format|
        format.xml  { render xml: @section.to_xml(methods: [:access_draw_type]) }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.xml { render xml: "<section></section>", status: :not_found }
      end
    end
end
