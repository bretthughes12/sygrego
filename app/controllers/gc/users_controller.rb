class Gc::UsersController < GcController
  
  load_and_authorize_resource except: [:create]
    
  # GET /gc/users
  def index
    @users = @group.users.
          order('name, email')

    render layout: @current_role.name
  end

  # GET /gc/users/1
  # 'show' must be explicitly invoked from the address bar - it is not available from the UI
  def show
    render layout: @current_role.name
  end

  # GET /gc/users/new
  def new
    render layout: @current_role.name
  end

  # GET /gc/users/1/edit
  def edit
    render layout: @current_role.name
  end
  
  # GET /gc/users/1/edit_password
  def edit_password
    render layout: @current_role.name
  end
  
  # POST /gc/users
  def create
    @user = User.find_by_email(params[:user][:email])

    if @user.nil?
      @user = User.new
    end

    @user.update(user_params)
    @user.status = 'Verified'
    @user.password = @user.password_confirmation = User.random_password

    respond_to do |format|
      if @user.save
        if @user.new_record?
          flash.now[:notice] = "GC #{@user.email} created"
        else
          flash.now[:notice] = "GC role added to #{@user.email}"
        end

        role = Role.find_by_name("gc")
        @user.roles << role unless @user.role?(:gc)
        @user.groups << @group unless @user.groups.include?(@group)

        @token = @user.get_reset_password_token
        UserMailer.gc_nomination(@user, @group, current_user, @token).deliver_now

        format.html { redirect_to gc_users_url }

      else
        format.html { render action: "new", layout: @current_role.name }
      end
    end
  end

  # PATCH /gc/users/1
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
  
  # PATCH /gc/users/1/update_password
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
