class Gc::EventDetailsController < GcController
    load_and_authorize_resource
  
    # GET /gc/event_details/1/edit
    def edit
      render layout: @current_role.name
    end
  
    # GET /gc/event_details/1/edit_orientation
    def edit_orientation
      @orientations = OrientationDetail.all.order(:name).load
      render layout: @current_role.name
    end
  
    # GET /gc/event_details/1/new_food_certificate
    def new_food_certificate
      render layout: @current_role.name
    end
  
    # GET /gc/event_details/1/new_covid_plan
    def new_covid_plan
      render layout: @current_role.name
    end
  
    # GET /gc/event_details/1/new_insurance
    def new_insurance
      render layout: @current_role.name
    end
  
    # PATCH /gc/event_details/1
    def update
      @event_detail.updated_by = current_user.id

      respond_to do |format|
        if @event_detail.update(event_detail_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "edit", layout: @current_role.name }
        end
      end
    end
  
    # PATCH /gc/event_details/1/udpate_orientation
    def update_orientation
      @event_detail.updated_by = current_user.id

      respond_to do |format|
        if @event_detail.update(event_detail_orientation_params)
          flash[:notice] = 'Orientation was successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html do
            @orientations = OrientationDetail.all.order(:name).load
            render action: "edit_orientation", layout: @current_role.name
          end
        end
      end
    end
  
    # PATCH /gc/event_details/1/update_food_certificate
    def update_food_certificate
      @event_detail.updated_by = current_user.id

      respond_to do |format|
        if @event_detail.update(event_detail_food_cert_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "new_food_certificate", layout: @current_role.name }
        end
      end
    end
  
    # PATCH /gc/event_details/1/update_covid_plan
    def update_covid_plan
      @event_detail.updated_by = current_user.id

      respond_to do |format|
        if @event_detail.update(event_detail_covid_plan_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "new_covid_plan", layout: @current_role.name }
        end
      end
    end
  
    # PATCH /gc/event_details/1/update_insurance
    def update_insurance
      @event_detail.updated_by = current_user.id

      respond_to do |format|
        if @event_detail.update(event_detail_insurance_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "new_insurance", layout: @current_role.name }
        end
      end
    end
  
    # PATCH /gc/event_details/1/purge_food_certificate
    def purge_food_certificate
      @event_detail.updated_by = current_user.id

      @event_detail.food_cert.purge

      respond_to do |format|
          format.html { render action: "new_food_certificate", layout: @current_role.name }
      end
    end
  
    # PATCH /gc/event_details/1/purge_covid_plan
    def purge_covid_plan
      @event_detail.updated_by = current_user.id

      @event_detail.covid_plan.purge

      respond_to do |format|
          format.html { render action: "new_covid_plan", layout: @current_role.name }
      end
    end
  
    # PATCH /gc/event_details/1/purge_insurance
    def purge_insurance
      @event_detail.updated_by = current_user.id

      @event_detail.insurance.purge

      respond_to do |format|
          format.html { render action: "new_insurance", layout: @current_role.name }
      end
    end

    private
  
    def event_detail_params
      params.require(:event_detail).permit(:onsite, 
                                    :fire_pit,
                                    :camping_rqmts,
                                    :tents,
                                    :caravans,
                                    :marquees,
                                    :marquee_sizes,
                                    :marquee_co,
                                    :buddy_interest,
                                    :buddy_comments,
                                    :service_pref_fri,
                                    :service_pref_sat,
                                    :service_pref_sun,
                                    :estimated_numbers,
                                    :number_of_vehicles
                                )
    end
  
    def event_detail_orientation_params
      params.require(:event_detail).permit(
                                    :orientation_detail_id
                                )
    end
  
    def event_detail_food_cert_params
      params.require(:event_detail).permit( 
                                    :food_cert
                                )
    end
  
    def event_detail_covid_plan_params
      params.require(:event_detail).permit( 
                                    :covid_plan
                                )
    end
  
    def event_detail_insurance_params
      params.require(:event_detail).permit( 
                                    :insurance
                                )
    end
end
