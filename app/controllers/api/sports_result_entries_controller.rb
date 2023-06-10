class Api::SportResultEntriesController < ApplicationController
    before_action :authorize_xml
    before_action :authenticate_user!
  
    # GET /api/sports/1.xml
    def show
        @sport_result_entry = SportResultEntry.find(params[:id])
      
        respond_to do |format|
            format.xml  { render xml: @sport_result_entry }
        end
        
    rescue ActiveRecord::RecordNotFound 
        respond_to do |format|
            format.xml { render xml: "<sport_result_entry></sport_result_entry>", status: :not_found }
        end
    end
end
