class Api::VenuesController < ApiController

    # GET /api/venues/1.xml
    def show
      @venue = Venue.find(params[:id])
      
      respond_to do |format|
        format.xml  { render xml: @venue }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.xml { render xml: "<venue></venue>", status: :not_found }
      end
    end
end
