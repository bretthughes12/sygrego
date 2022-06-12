class LostItemsController < ApplicationController

  load_and_authorize_resource
  layout 'users'
  
  # GET /lost_items
  def index
    @lost_items = LostItem.unclaimed.order(:description).load

    respond_to do |format|
      format.html # lost_items.html.erb
    end
  end

  # GET /admin/lost_items/search
  def search
    @lost_items = LostItem.unclaimed.search(params[:search]).order(:description).load

    respond_to do |format|
      format.html { render action: 'index' }
    end
  end
  
  # GET /lost_items/1
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  # GET /lost_items/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end
  
  # PATCH /lost_items/1
  def update
    begin
      @lost_item.claimed = true

      respond_to do |format|
        if @lost_item.update(lost_item_params)
          flash[:notice] = 'Lost property claimed'
          LostItemMailer.claimed_item(@lost_item).deliver_now
          format.html do
            redirect_to lost_items_url
          end
        else
          format.html { render action: "edit" }
        end
      end
      
    rescue ActiveRecord::StaleObjectError
      flash[:notice] = 'Somebody else has updated / claimed this item.'

      redirect_to lost_items_url
    end
  end

  private

  def lost_item_params
    params.require(:lost_item).permit(
      :lock_version,
      :name, 
      :address, 
      :suburb,
      :postcode,
      :phone_number,
      :email
    )
  end
end  