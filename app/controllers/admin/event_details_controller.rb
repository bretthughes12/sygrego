class Admin::EventDetailsController < ApplicationController
    require 'csv'

    load_and_authorize_resource except: [:show]
    before_action :authenticate_user!
    
    layout "admin"
  
    # GET /admin/event_details
    def index
      @event_details = EventDetail.includes(:group).all.order("groups.abbr").load
  
      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "event_detail", "event_detail" }
      end
    end

    # GET /admin/event_details/1
    # GET /admin/event_details/1.xml
    # 'show' must be explicitly invoked from the address bar - it is not available from the UI
    def show
      @event_detail = EventDetail.find(params[:id])
      authorize! :show, @event_detail
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render xml: @event_detail }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.html { raise }
        format.xml { render xml: "<event-detail></event-detail>", status: :not_found }
      end
    end
  
    # GET /admin/event_details/1/edit
    def edit
    end
  
    # PUT /admin/event_details/1
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
  
    # GET /admin/event_details/new_import
    def new_import
      @event_detail = EventDetail.new
    end
  
    # POST /admin/event_details/import
    def import
      if params[:event_detail][:file].path =~ %r{\.csv$}i
        result = EventDetail.import(params[:event_detail][:file], current_user)

        flash[:notice] = "Event Details upload complete: #{result[:creates]} event_details created; #{result[:updates]} updates; #{result[:errors]} errors"

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
                                    :number_of_vehicles
                                )
    end
end
