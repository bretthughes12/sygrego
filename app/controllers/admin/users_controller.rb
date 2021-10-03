class Admin::UsersController < ApplicationController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'admin'
    
    # GET /admin/users
    def index
      @users = User.order(:email).load

      respond_to do |format|
        format.html # index.html.erb
      end
    end
  
    # GET /admin/users/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/users/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/users/1/edit
    def edit
    end
  
    # POST /admin/users
    def create
      respond_to do |format|
        if @user.save
          flash[:notice] = 'User was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PUT /admin/users/1
    def update
      respond_to do |format|
        if @user.update(user_params)
          flash[:notice] = 'User was successfully updated.'
          format.html { redirect_to admin_users_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/users/1
    def destroy
      @user.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_users_url }
      end
    end
  
    private
    
    def user_params
      params.require(:user).permit(:email, 
                                   :password,
                                   :password_confirmation)
    end
end
