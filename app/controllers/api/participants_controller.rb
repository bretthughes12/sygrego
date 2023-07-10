class Api::ParticipantsController < ApiController
    
    # GET /api/participants/1.xml
    def show
      @participant = Participant.find(params[:id])
      
      respond_to do |format|
        format.xml  { render xml: @participant }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.xml { render xml: "<participant></participant>", status: :not_found }
      end
    end
end
