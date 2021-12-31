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

    # GET /admin/users/search
    def search
      @users = User.search(params[:search]).order("email")
  
      respond_to do |format|
        format.html { render action: 'index' }
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
      @user.status = "Verified"
      
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/users/1/edit
    def edit
      @user_roles = Role.order(:name).load
      @groups = @user.other_groups
    end
  
    # GET /admin/users/1/edit_password
    def edit_password
    end
  
    # GET /admin/users/1/profile
    def profile
    end
  
    # POST /admin/users
    def create
      respond_to do |format|
        if @user.save
          flash[:notice] = 'User was successfully created.'
          format.html do 
            @user_roles = Role.order(:name).load
            @groups = @user.other_groups
            render action: "edit" 
          end
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
            format.html do 
              @user_roles = Role.order(:name).load
              @groups = @user.other_groups
              render action: "edit" 
            end
        end
      end
    end
  
    # PUT /admin/users/1/update_password
    def update_password
      respond_to do |format|
        if @user.update(user_password_params)
          flash[:notice] = 'Password updated.'
          bypass_sign_in(@user)
          format.html { redirect_to home_url(@user) }
        else
          format.html { render action: "edit_password" }
        end
      end
    end
  
    # PUT /admin/users/1/update_profile
    def update_profile
      respond_to do |format|
        if @user.update(user_params)
          flash[:notice] = 'Profile updated.'
          format.html { redirect_to home_url(@user) }
        else
          format.html { render action: "profile" }
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
                                   :password_confirmation,
                                   :name,
                                   :status,
                                   :address,
                                   :suburb,
                                   :postcode,
                                   :phone_number,
                                   :wwcc_number,
                                   :group_role,
                                   :years_as_gc
                                  )
    end
    
    def user_password_params
      params.require(:user).permit(:password,
                                   :password_confirmation,
                                  )
    end
end
