class Gc::GroupsController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout "gc"
  
    # GET /gc/groups/1/edit
    def edit
    end
  
    # PUT /gc/groups/1
    def update
      @group.updated_by = current_user.id

      respond_to do |format|
        if @group.update(group_params)
          flash[:notice] = 'Successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "edit" }
        end
      end
    end

    # GET /gc/groups/available_groups
    def available_groups
      if session["current_group"]
        current_group = Group.find_by_abbr(session["current_group"])
        @groups = current_user.groups - [current_group]
      else
        @groups = current_user.groups
      end

      current_role = Role.find_by_name(session["current_role"])
      render layout: current_role.name
    end

    # PATCH /gc/group/1/switch
    def switch
      session["current_group"] = @group.abbr

      respond_to do |format|
        format.html { redirect_to home_url(current_user) }
      end
    end
  
private
  
    def group_params
      params.require(:group).permit(:abbr, 
                                    :name, 
                                    :short_name,
                                    :coming,
                                    :lock_version,
                                    :trading_name,
                                    :address,
                                    :suburb,
                                    :postcode,
                                    :phone_number,
                                    :email,
                                    :website,
                                    :denomination,
                                    :years_attended,
                                    :age_demographic,
                                    :group_focus
                                )
    end
end
