class ParticipantsController < ApplicationController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    before_action :find_participant
    
    # GET /participants/available_participants
    def available_participants
      if session["current_participant"]
        @participants = current_user.available_participants - [@participant]
      else
        @participants = current_user.available_participants
      end

      render layout: current_role.name
    end

    # PATCH /participant/1/switch
    def switch
      participant = Participant.find(params[:id])
      session["current_participant"] = participant.id
      session["current_group"] = participant.group.id
      session["current_role"] = "participant"

      respond_to do |format|
        format.html { redirect_to home_url(current_user) }
      end
    end

    private

    def find_participant
      if session["current_participant"]
        @participant = Participant.where(id: session["current_participant"]).first
      end
    end
  end
