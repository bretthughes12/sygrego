class GroupsController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    before_action :find_participant
    
    # GET /gc/groups/available_groups
    def available_groups
      if session["current_group"]
        current_group = Group.find_by_id(session["current_group"])
        @groups = current_user.available_groups - [current_group]
      else
        @groups = current_user.available_groups
      end

      render layout: current_role.name
    end

    # PATCH /gc/group/1/switch
    def switch
      session["current_group"] = @group.id
      unless session["current_role"] == "church_rep" || session["current_role"] == "gc"
        session["current_role"] = current_user.church_rep_or_gc_role.to_s
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
