class Admin::GroupsController < ApplicationController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout "admin"
  
    # GET /admin/groups
    def index
      @groups = Group.order(:abbr).load
  
      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "group", "group" }
      end
    end

    # GET /admin/groups/search
    def search
      @groups = Group.search(params[:search]).order("abbr")
  
      respond_to do |format|
        format.html { render action: 'index' }
      end
    end
    
    # GET /admin/groups/1
    def show
    end
  
    # GET /admin/groups/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/groups/1/edit
    def edit
    end
  
    # POST /admin/groups
    def create
        @group = Group.new(group_params)
        @group.updated_by = current_user.id

        respond_to do |format|
            if @group.save
                flash[:notice] = 'Group was successfully created.'
                format.html { render action: "edit" }
            else
                format.html { render action: "new" }
            end
        end
    end
  
    # PUT /admin/groups/1
    def update
      @group.updated_by = current_user.id

      respond_to do |format|
        if @group.update(group_params)
          flash[:notice] = 'Group was successfully updated.'
          format.html { redirect_to admin_groups_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/groups/1
    def destroy
        @group.updated_by = current_user.id

#        if @group.sections.empty?
            @group.destroy
  
            respond_to do |format|
                format.html { redirect_to admin_groups_url }
            end
        
#          else
#            flash[:notice] = "Can't delete, as sections exist"
#        
#            respond_to do |format|
#                format.html { redirect_to admin_groups_url }
#            end
#        end
    end
  
    # GET /admin/groups/new_import
    def new_import
      @group = Group.new
    end
  
    # POST /admin/groups/import
    def import
      if params[:group] && params[:group][:file].path =~ %r{\.csv$}i
        result = Group.import(params[:group][:file], current_user)

        flash[:notice] = "Groups upload complete: #{result[:creates]} groups created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_groups_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
        @group = Group.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end
  
    # PATCH /admin/user/1/groups/add_group
    def add_group
      @user = User.find(params[:user_id])
      @group = Group.find(params[:group_id])

      @user.groups << @group unless @user.groups.include?(@group)

      respond_to do |format|
        format.html { redirect_to edit_admin_user_url(@user) }
      end
    end
  
    # DELETE /admin/user/1/group/1/purge
    def purge
      @user = User.find(params[:user_id])

      @user.groups.delete(@group)
  
      respond_to do |format|
        format.html { redirect_to edit_admin_user_url(@user) }
      end
    end

private
  
    def group_params
      params.require(:group).permit(:abbr, 
                                    :name, 
                                    :short_name,
                                    :coming,
                                    :lock_version,
                                    :new_group,
                                    :trading_name,
                                    :address,
                                    :suburb,
                                    :postcode,
                                    :phone_number,
                                    :last_year,
                                    :admin_use,
                                    :late_fees,
                                    :email,
                                    :website,
                                    :denomination,
                                    :years_attended,
                                    :status,
                                    :age_demographic,
                                    :group_focus
                                )
    end
end
