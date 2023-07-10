class Api::VolunteerTypesController < ApiController

    # GET /api/volunteer_types/1.xml
    def show
      @volunteer_type = VolunteerType.find(params[:id])
      
      respond_to do |format|
        format.xml  { render xml: @volunteer_type }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.xml { render xml: "<volunteer_type></volunteer_type>", status: :not_found }
      end
    end
end
