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
          format.html { render action: "edit" }
        else
          format.html { render action: "edit" }
        end
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
