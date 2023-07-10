class Admin::LostItemsController < AdminController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    # GET /admin/lost_items
    def index
      @lost_items = LostItem.order(:description).load

      respond_to do |format|
        format.html # index.html.erb
      end
    end
  
    # GET /admin/lost_items/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/lost_items/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/lost_items/1/edit
    def edit
    end
  
    # POST /admin/lost_items
    def create
      respond_to do |format|
        if @lost_item.save
          flash[:notice] = 'Lost Item was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/lost_items/1
    def update
      respond_to do |format|
        if @lost_item.update(lost_item_params)
          flash[:notice] = 'Lost Item was successfully updated.'
          format.html { redirect_to admin_lost_items_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # PATCH /admin/lost_items/1/purge_photo
    def purge_photo
      @lost_item.photo.purge

      respond_to do |format|
        format.html { render action: "edit" }
      end
    end
  
    # DELETE /admin/lost_items/1
    def destroy
      @lost_item.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_lost_items_url }
      end
    end
  
    private
    
    def lost_item_params
      params.require(:lost_item).permit(
        :category, 
        :description,
        :notes,
        :claimed,
        :lock_version,
        :name,
        :address,
        :suburb,
        :postcode,
        :email,
        :phone_number,
        :photo
      )
    end
  end
  