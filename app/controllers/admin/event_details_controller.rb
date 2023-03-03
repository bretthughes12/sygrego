class Admin::EventDetailsController < ApplicationController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout "admin"
  
    # GET /admin/event_details
    def index
      @event_details = EventDetail.includes(:group).where("groups.coming = true").all.order("groups.abbr").load
  
      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "event_detail", "event_detail" }
      end
    end

    # GET /admin/event_details/search
    def search
      @groups = Group.search(params[:search]).order("abbr")
      @event_details = @groups.collect(&:event_detail)
  
      respond_to do |format|
        format.html { render action: 'index' }
      end
    end
  
    # GET /admin/event_details/uploads
    def uploads
      @event_details = EventDetail.includes(:group).where("groups.coming = true").all.order("groups.abbr").load
  
      respond_to do |format|
        format.html # index.html.erb
      end
    end

    # GET /admin/event_details/warden_zones
    def warden_zones
      @event_details = EventDetail.includes(:group).where("groups.coming = true").all.order("groups.abbr").load
  
      respond_to do |format|
        format.html # index.html.erb
      end
    end

    # GET /admin/event_details
    def orientation_details
      @event_details = EventDetail.includes(:group).where("groups.coming = true").all.order("groups.abbr").load
  
      respond_to do |format|
        format.html # orientation_details.html.erb
      end
    end

    # GET /admin/event_details/1
    def show
    end
  
    # GET /admin/event_details/1/edit
    def edit
    end
  
    # GET /admin/event_details/1/edit_warden_zone
    def edit_warden_zone
    end
  
    # PATCH /admin/event_details/1
    def update
      @event_detail.updated_by = current_user.id

      respond_to do |format|
        if @event_detail.update(event_detail_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to admin_event_details_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # PATCH /admin/event_details/1/update_warden_zone
    def update_warden_zone
      @event_detail.updated_by = current_user.id

      respond_to do |format|
        if @event_detail.update(event_detail_warden_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to warden_zones_admin_event_details_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # PATCH /admin/event_details/update_multiple_orientations
    def update_multiple_orientations
      params[:event_details].keys.each do |id|
        event_detail = EventDetail.find(id.to_i)
        event_detail.updated_by = current_user.id
        event_detail.update(event_details_orientation_params(id))
      end
      flash[:notice] = "Details updated"

      respond_to do |format|
        format.html { redirect_to orientation_details_admin_event_details_path }
      end
    end
  
    # PATCH /admin/event_details/1/purge_file
    def purge_file
      @event_detail.updated_by = current_user.id

      @event_detail.food_cert.purge

      respond_to do |format|
          format.html { render action: "edit" }
      end
    end

    # GET /admin/event_details/new_import
    def new_import
      @event_detail = EventDetail.new
    end
  
    # POST /admin/event_details/import
    def import
      if params[:event_detail] && params[:event_detail][:file].path =~ %r{\.csv$}i
        result = EventDetail.import(params[:event_detail][:file], current_user)

        flash[:notice] = "Event Details upload complete: #{result[:creates]} details created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_event_details_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
        @event_detail = EventDetail.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
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
                                    :service_pref_sat,
                                    :service_pref_sun,
                                    :estimated_numbers,
                                    :number_of_vehicles,
                                    :orientation_details,
                                    :food_cert,
                                    :warden_zone_id
                                )
    end
  
    def event_detail_warden_params
      params.require(:event_detail).permit(
                                    :warden_zone_id
                                )
    end
  
    def event_details_orientation_params(id)
      params.require(:event_details)
            .fetch(id)
            .permit(:orientation_details)
    end
end
