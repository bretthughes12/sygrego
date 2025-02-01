class Admin::OrientationDetailsController < AdminController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    # GET /admin/orientation_details
    def index
      @orientation_details = OrientationDetail.order(:name).load

      respond_to do |format|
        format.html # index.html.erb
      end
    end
  
    # GET /admin/orientation_details/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/orientation_details/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/orientation_details/1/edit
    def edit
    end
  
    # POST /admin/orientation_details
    def create
      respond_to do |format|
        if @orientation_detail.save
          flash[:notice] = 'Orientation details were successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/orientation_details/1
    def update
      respond_to do |format|
        if @orientation_detail.update(orientation_detail_params)
          flash[:notice] = 'Orientation details were successfully updated.'
          format.html { redirect_to admin_orientation_details_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/orientation_details/1
    def destroy
      @orientation_detail.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_orientation_details_url }
      end
    end
  
    private
    
    def orientation_detail_params
      params.require(:orientation_detail).permit(:name, 
                                   :venue_name,
                                   :venue_address,
                                   :event_date_time)
    end
end
