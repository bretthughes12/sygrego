class Gc::GroupsController < GcController
    load_and_authorize_resource
  
    # GET /gc/groups/1/edit
    def edit
      render layout: @current_role.name
    end
  
    # PATCH /gc/groups/1
    def update
      @group.updated_by = current_user.id

      respond_to do |format|
        if @group.update(group_params)
          flash[:notice] = 'Successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "edit", layout: @current_role.name }
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
                                    :ticket_preference,
                                    :ticket_email,
                                    :denomination,
                                    :years_attended,
                                    :age_demographic,
                                    :group_focus
                                )
    end
end
