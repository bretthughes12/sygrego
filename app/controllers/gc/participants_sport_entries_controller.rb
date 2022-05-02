class Gc::ParticipantsSportEntriesController < ApplicationController
    authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    
    layout "gc" 
  
    # PATCH /gc/sport_entries/1/participants/1/make_captain
    def make_captain
        @sport_entry = SportEntry.find(params[:sport_entry_id])
        @sport_entry.captaincy_id = params[:id]
        @sport_entry.save
    
        respond_to do |format|
            format.html { redirect_to(edit_gc_sport_entry_url(@sport_entry)) }
        end
    end

    # POST /gc/1/sport_entries/1/participants
    # POST /gc/1/participants/1/sport_entries
    def create
        if params[:sport_entry_id]
            @sport_entry = SportEntry.find(params[:sport_entry_id])
            @participant = Participant.find(params[:id])
        else
            @sport_entry = SportEntry.find(params[:id])
            @participant = Participant.find(params[:participant_id])
        end
      
        @sport_entry.participants << @participant unless @sport_entry.participants.include?(@participant)
        flash[:notice] = 'Participant added to sport entry.'
      
        respond_to do |format|
            format.html do 
                if params[:return] && params[:return] == 'edit_sports'
                    redirect_to(edit_sports_gc_participant_path(@participant)) 
                else
                    redirect_to(edit_gc_sport_entry_url(@sport_entry)) 
                end
            end
        end
    end
  
    # DELETE /groups/1/sport_entries/1/participants/1
    # DELETE /groups/1/participants/1/sport_entries/1
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
            format.html do 
                if params[:return] && params[:return] == 'edit_sports'
                    redirect_to(edit_sports_gc_participant_path(@participant)) 
                else
                    redirect_to(edit_gc_sport_entry_url(@sport_entry)) 
                end
            end
        end
    end
end
  