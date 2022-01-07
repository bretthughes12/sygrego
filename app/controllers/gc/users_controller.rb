class Gc::UsersController < ApplicationController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    
    layout 'gc'
    
    # GET /admin/users/1/edit
    def edit
      render layout: @current_role.name
    end
  
    # GET /admin/users/1/edit_password
    def edit_password
      render layout: @current_role.name
    end
  
    # PATCH /admin/users/1
    def update
      respond_to do |format|
        if @user.update(user_params)
          flash[:notice] = 'Profile updated.'
          format.html { redirect_to home_url(current_user) }
        else
          format.html { render action: "edit", layout: @current_role.name }
        end
      end
    end
  
    # PATCH /admin/users/1/update_password
    def update_password
      respond_to do |format|
        if @user.update(user_password_params)
          flash[:notice] = 'Password updated.'
          bypass_sign_in(@user)
          format.html { redirect_to home_url(@user) }
        else
          format.html { render action: "edit_password", layout: @current_role.name }
        end
      end
    end
  
    private
    
    def user_params
      params.require(:user).permit(:email, 
                                   :password,
                                   :password_confirmation,
                                   :name,
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
