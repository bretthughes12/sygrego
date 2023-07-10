class Api::SportsController < ApiController
 
    # GET /api/sports/1.xml
    def show
        @sport = Sport.find(params[:id])
      
        respond_to do |format|
            format.xml  { render xml: @sport }
        end
        
    rescue ActiveRecord::RecordNotFound 
        respond_to do |format|
            format.xml { render xml: "<sport></sport>", status: :not_found }
        end
    end
end
