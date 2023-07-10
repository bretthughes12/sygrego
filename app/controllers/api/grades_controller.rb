class Api::GradesController < ApiController
    
    # GET /api/grades/1.xml
    def show
      @grade = Grade.find(params[:id])
      
      respond_to do |format|
        format.xml  { render xml: @grade }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.xml { render xml: "<grade></grade>", status: :not_found }
      end
    end
end
