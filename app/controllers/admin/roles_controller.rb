class Admin::RolesController < ApplicationController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'admin'
    
    # GET /admin/roles
    def index
      @roles = Role.order(:name).load

      respond_to do |format|
        format.html # index.html.erb
      end
    end
  
    # GET /admin/roles/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/roles/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/roles/1/edit
    def edit
    end
  
    # POST /admin/roles
    def create
      respond_to do |format|
        if @role.save
          flash[:notice] = 'Role was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PUT /admin/roles/1
    def update
      respond_to do |format|
        if @role.update(role_params)
          flash[:notice] = 'Role was successfully updated.'
          format.html { redirect_to admin_roles_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/roles/1
    def destroy
      @role.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_roles_url }
      end
    end
  
    private
    
    def role_params
      params.require(:role).permit(:name, 
                                   :group_related,
                                   :participant_related)
    end
end
