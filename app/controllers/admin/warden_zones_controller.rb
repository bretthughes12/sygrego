class Admin::WardenZonesController < AdminController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    # GET /admin/warden_zones
    def index
      @warden_zones = WardenZone.order(:zone).load

      respond_to do |format|
        format.html # index.html.erb
      end
    end
  
    # GET /admin/warden_zones/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/warden_zones/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/warden_zones/1/edit
    def edit
    end
  
    # POST /admin/warden_zones
    def create
      @warden_zone = WardenZone.new(warden_zone_params)

      respond_to do |format|
        if @warden_zone.save
          flash[:notice] = 'Warden Zone was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/warden_zones/1
    def update
      respond_to do |format|
        if @warden_zone.update(warden_zone_params)
          flash[:notice] = 'Warden Zone was successfully updated.'
          format.html { redirect_to admin_warden_zones_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/warden_zones/1
    def destroy
      flash[:notice] = 'Warden Zone deleted.'
      @warden_zone.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_warden_zones_url }
      end
    end
  
    private
    
    def warden_zone_params
      params.require(:warden_zone).permit(
        :zone, 
        :warden_info
      )
    end
  end
  