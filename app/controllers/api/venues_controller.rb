class Api::VenuesController < ApplicationController
    before_action :authorize_xml
    before_action :authenticate_user!

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
