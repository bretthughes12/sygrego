class Api::EventDetailsController < ApiController
    
    # GET /api/event_details/1.xml
    def show
      @event_detail = EventDetail.find(params[:id])
      
      respond_to do |format|
        format.xml  { render xml: @event_detail }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.xml { render xml: "<event-detail></event-detail>", status: :not_found }
      end
    end
end
