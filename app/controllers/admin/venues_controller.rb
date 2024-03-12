class Admin::VenuesController < AdminController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
  
    # GET /admin/venues
    def index
      @venues = Venue.order("name").includes(:sections).all
  
      respond_to do |format|
        format.html {  }
        format.csv  { render_csv "sport_venue" }
        format.xlsx { render xlsx: "index", filename: "venues.xlsx" }
      end
    end
  
    # GET /admin/venues/1
    def show
    end
  
    # GET /admin/venues/new
    def new
      respond_to do |format|
        format.html # new.html.erb
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
  
    # PATCH /admin/venues/1
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

        if @venue.sections.empty?
          @venue.destroy
  
            respond_to do |format|
                format.html { redirect_to admin_venues_url }
            end
        
          else
            flash[:notice] = "Can't delete, as sections exist"
        
            respond_to do |format|
                format.html { redirect_to admin_venues_url }
            end
        end
    end

    # GET /admin/venues/new_import
    def new_import
      @venue = Venue.new
    end
  
    # POST /admin/venues/import
    def import
      if params[:venue] && params[:venue][:file].path =~ %r{\.xlsx$}i
        result = Venue.import_excel(params[:venue][:file], current_user)

        flash[:notice] = "Venues upload complete: #{result[:creates]} venues created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_venues_url }
        end
      else
        flash[:notice] = "Upload file must be in '.xlsx' format"
        @venue = Venue.new

        respond_to do |format|
          format.html { render action: "new_import" }
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
