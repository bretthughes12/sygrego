class RolesController < ApplicationController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    
    # GET /admin/roles/available_roles
    def available_roles
      current_role = Role.find_by_name(session["current_role"])
      @roles = current_user.roles - [current_role]

      render layout: current_role.name
    end

    # PATCH /admin/role/1/switch
    def switch
      session["current_role"] = @role.name
      session["current_group"] = nil unless @role.group_related

      respond_to do |format|
        format.html { redirect_to home_url(current_user) }
      end
    end
  end
