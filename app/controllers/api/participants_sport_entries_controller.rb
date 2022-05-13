class Api::ParticipantsSportEntriesController < ApplicationController
    before_action :authorize_xml
    before_action :authenticate_user!
    
    # GET /api/sport_entries/1/participants.xml
    def index
      @sport_entry = SportEntry.find(params[:sport_entry_id])
      @participants = @sport_entry.participants
      
      respond_to do |format|
        format.xml  { render xml: @participants }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.xml { render xml: "<participant></participant>", status: :not_found }
      end
    end
end
