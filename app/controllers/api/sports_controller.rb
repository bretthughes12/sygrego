class Api::SportsController < ApplicationController
    before_action :authorize_xml
    before_action :authenticate_user!
  
    # GET /api/sports/1.xml
    def show
        @sport = Sport.find(params[:id])
      
        respond_to do |format|
            format.html { authorize! :show, @sport }
            format.xml  { render xml: @sport }
        end
        
    rescue ActiveRecord::RecordNotFound 
        respond_to do |format|
            format.html { raise }
            format.xml { render xml: "<sport></sport>", status: :not_found }
        end
    end
end
