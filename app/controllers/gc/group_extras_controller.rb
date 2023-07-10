class Gc::GroupExtrasController < GcController
    load_and_authorize_resource
  
    # GET /gc/group_extras
    def index
      @group_extras = @group.group_extras.
        order(:name).load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end

    # GET /gc/group_extras/1
    def show
      render layout: @current_role.name
    end
  
    # GET /gc/group_extras/new
    def new
      respond_to do |format|
        format.html { render layout: @current_role.name }
      end
    end
  
    # GET /gc/group_extras/1/edit
    def edit
      render layout: @current_role.name
    end
  
    # POST /admin/group_extras
    def create
      @group_extra = GroupExtra.new(group_extra_params)
      @group_extra.group_id = @group.id

      respond_to do |format|
          if @group_extra.save
              flash[:notice] = 'Extra item was successfully created.'
              format.html { render action: "edit", layout: @current_role.name }
          else
              format.html { render action: "new", layout: @current_role.name }
          end
      end
    end

    # PATCH /gc/group_extras/1
    def update
        respond_to do |format|
          if @group_extra.update(group_extra_params)
            flash[:notice] = 'Details were successfully updated.'
            format.html { redirect_to gc_group_extras_url }
          else
            format.html { render action: "edit", layout: @current_role.name }
          end
        end
    end
  
    # DELETE /admin/group_extras/1
    def destroy
        flash[:notice] = 'Extra item deleted.'
        @group_extra.destroy

        respond_to do |format|
            format.html { redirect_to gc_group_extras_url }
        end
    end
  
    private
  
    def group_extra_params
      params.require(:group_extra).permit(
        :name, 
        :cost,
        :needs_size,
        :optional,
        :show_comment,
        :comment_prompt
      )
    end
end
