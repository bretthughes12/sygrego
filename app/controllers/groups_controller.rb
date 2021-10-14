class GroupsController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    
    # GET /gc/groups/available_groups
    def available_groups
      if session["current_group"]
        current_group = Group.find_by_abbr(session["current_group"])
        @groups = current_user.available_groups - [current_group]
      else
        @groups = current_user.available_groups
      end

      current_role = Role.find_by_name(session["current_role"])
      render layout: current_role.name
    end

    # PATCH /gc/group/1/switch
    def switch
      session["current_group"] = @group.abbr
      session["current_role"] = "gc"

      respond_to do |format|
        format.html { redirect_to home_url(current_user) }
      end
    end
end
