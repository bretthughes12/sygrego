class Api::SessionsController < ApiController
   
    # GET /api/sessions/1.xml
    def show
      @session = Session.find(params[:id])
      
      respond_to do |format|
        format.xml  { render xml: @session }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.xml { render xml: "<session></session>", status: :not_found }
      end
    end
end
