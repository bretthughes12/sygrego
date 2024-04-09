class Gc::GroupFeeCategoriesController < GcController
    load_and_authorize_resource
  
    # GET /gc/group_fee_categories
    def index
      @group_fee_categories = @group.group_fee_categories.
        order(:description).load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end

    # GET /gc/group_fee_categories/1
    def show
      render layout: @current_role.name
    end
  
    # GET /gc/group_fee_categories/new
    def new
      respond_to do |format|
        format.html { render layout: @current_role.name }
      end
    end
  
    # GET /gc/group_fee_categories/1/edit
    def edit
      render layout: @current_role.name
    end
  
    # POST /admin/group_fee_categories
    def create
      @group_fee_category = GroupFeeCategory.new(group_fee_category_params)
      @group_fee_category.group_id = @group.id

      respond_to do |format|
          if @group_fee_category.save
              flash[:notice] = 'Fee category was successfully created.'
              format.html { render action: "edit", layout: @current_role.name }
          else
              format.html { render action: "new", layout: @current_role.name }
          end
      end
    end

    # PATCH /gc/group_fee_categories/1
    def update
        respond_to do |format|
          if @group_fee_category.update(group_fee_category_params)
            flash[:notice] = 'Details were successfully updated.'
            format.html { redirect_to gc_group_fee_categories_url }
          else
            format.html { render action: "edit", layout: @current_role.name }
          end
        end
    end
  
    # DELETE /admin/group_fee_categories/1
    def destroy
        flash[:notice] = 'Fee category deleted.'
        @group_fee_category.destroy

        respond_to do |format|
            format.html { redirect_to gc_group_fee_categories_url }
        end
    end
  
    private
  
    def group_fee_category_params
      params.require(:group_fee_category).permit(
        :description, 
        :adjustment_type,
        :amount,
        :expiry_date
      )
    end
end
  