class Admin::ParticipantsSportEntriesController < ApplicationController
    authorize_resource
    before_action :authenticate_user!
    
    layout "admin" 
  
    # PATCH /admin/sport_entries/1/participants/1/make_captain
    def make_captain
        @sport_entry = SportEntry.find(params[:sport_entry_id])
        @sport_entry.captaincy_id = params[:id]
        @sport_entry.save
    
        respond_to do |format|
            format.html { redirect_to(edit_admin_sport_entry_url(@sport_entry)) }
        end
    end

    # POST /admin/1/sport_entries/1/participants
    def create
        @sport_entry = SportEntry.find(params[:sport_entry_id])
        @participant = Participant.find(params[:id])
      
        @sport_entry.participants << @participant unless @sport_entry.participants.include?(@participant)
        flash[:notice] = 'Participant added to sport entry.'
      
        respond_to do |format|
            format.html { redirect_to(edit_admin_sport_entry_url(@sport_entry)) }
        end
    end
  
    # DELETE /groups/1/sport_entries/1/participants/1
    def destroy
        @sport_entry = SportEntry.find(params[:sport_entry_id])
        @participant = Participant.find(params[:id])
  
        @sport_entry.participants.delete(@participant)
      
        if @sport_entry.captaincy == @participant
            @sport_entry.captaincy = nil
            @sport_entry.save
        end
        flash[:notice] = "Participant removed from sport entry"
  
        respond_to do |format|
            format.html { redirect_to(edit_admin_sport_entry_url(@sport_entry)) }
        end
    end
end
  