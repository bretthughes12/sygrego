class RolesController < ApplicationController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    before_action :find_participant
    
    # GET /admin/roles/available_roles
    def available_roles
      @roles = current_user.roles - [current_role]

      render layout: current_role.name
    end

    # PATCH /admin/role/1/switch
    def switch
      session["current_role"] = @role.name
      if @role.group_related 
        session["current_group"] = current_user.default_group unless session["current_group"]
      else
        session["current_group"] = nil 
      end
      if @role.name == "participant"
        session["current_participant"] = current_user.default_participant
        participant = Participant.find(current_user.default_participant)
        session["current_group"] = participant.group.id
      else
        session["current_participant"] = nil
      end

      respond_to do |format|
        format.html { redirect_to home_url(current_user) }
      end
    end

    private

    def find_participant
      if session["current_participant"]
        @participant = Participant.where(id: session["current_participant"]).first
      elsif current_user && !current_user.participants.empty?
        @participant = Participant.where(id: current_user.participants.first.id).first
      end
    end

  end
