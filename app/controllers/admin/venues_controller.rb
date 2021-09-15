class Admin::VenuesController < ApplicationController
    require 'csv'

    load_and_authorize_resource except: [:show]
    before_action :authenticate_user!
  
    layout "admin"
  
    # GET /admin/venues
    def index
#      page_sym = save_page("Venue", params)
#      session[page_sym] = params[:page].to_i if params[:page]
  
      @venues = Venue.order("name").all
  
      respond_to do |format|
        format.html {  }
#        format.html { @venues = @venues.paginate(page: session[page_sym]) }
        format.xml  { render xml: @venues }
        format.csv  { render_csv "sport_venue" }
      end
    end
  
    # GET /admin/venues/1
    # GET /admin/venues/1.xml
    # 'show' must be explicitly invoked from the address bar - it is not available from the UI
    def show
      @venue = Venue.find(params[:id])
      authorize! :show, @venue
#      @venue_map = @venue.to_gmaps4rails unless @venue.lat.nil? or @venue.lng.nil? 
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render xml: @venue }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.html { raise }
        format.xml { render xml: "<venue></venue>", status: :not_found }
      end
    end
  
    # GET /admin/venues/new
    def new
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render xml: @venue }
      end
    end
  
    # GET /admin/venues/1/edit
    def edit
    end
  
    # POST /admin/venues
    def create
        @venue = Venue.new(venue_params)
        @venue.updated_by = current_user.id

        respond_to do |format|
            if @venue.save
                flash[:notice] = 'Venue was successfully created.'
                format.html { render action: "edit" }
            else
                format.html { render action: "new" }
            end
        end
    end
  
    # PUT /admin/venues/1
    def update
        @venue.updated_by = current_user.id

        respond_to do |format|
          if @venue.update(venue_params)
            flash[:notice] = 'Venue was successfully updated.'
            format.html { redirect_to admin_venues_url }
          else
            format.html { render action: "edit" }
          end
        end
    end
  
    # DELETE /venues/1
    def destroy
        @venue.updated_by = current_user.id

        begin
            @venue.destroy
  
            respond_to do |format|
                format.html { redirect_to admin_venues_url }
            end

        rescue Exception
            flash[:notice] = "Can't delete, as section(s) are defined using this venue"
        
            respond_to do |format|
                format.html { redirect_to admin_venues_url }
            end
        end
    end
  
  private
  
    def venue_params
      params.require(:venue).permit(:name, 
                                    :database_code, 
                                    :active,
                                    :address)
    end
  end
