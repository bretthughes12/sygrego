class Api::SessionsController < ApplicationController
    before_action :authorize_xml
    before_action :authenticate_user!
    
    # GET /api/sessions/1.xml
    def show
      @session = Session.find(params[:id])
      
      respond_to do |format|
        format.html { authorize! :show, @session }
        format.xml  { render xml: @session }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.html { raise }
        format.xml { render xml: "<session></session>", status: :not_found }
      end
    end
end
