class Api::RoundRobinMatchesController < ApiController
  
    # GET /api/round_robin_matches/1.xml
    def show
        @round_robin_match = RoundRobinMatch.find(params[:id])
      
        respond_to do |format|
            format.xml  { render xml: @round_robin_match }
        end
        
    rescue ActiveRecord::RecordNotFound 
        respond_to do |format|
            format.xml { render xml: "<round_robin_match></round_robin_match>", status: :not_found }
        end
    end
end
