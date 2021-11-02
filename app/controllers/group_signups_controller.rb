class GroupSignupsController < ApplicationController

    layout 'users'
  
    # GET /group_signups/new
    def new
      @group_signup = GroupSignup.new
      @groups = Group.order(:name).load
  
      respond_to do |format|
        format.html # new.html.erb
      end
    end
    
    # POST /group_signups
    def create
      @group_signup = GroupSignup.new(params[:group_signup])
  
      respond_to do |format|
        if @group_signup.save
          @group = @group_signup.group
          
          @gc = @group_signup.gc
          @church_rep = @group_signup.church_rep
          
#          if @group.lock_version == 0
#            log(@group, "CREATE")
#          else
#            log(@group, "UPDATE")
#          end
    
          GroupMailer.new_group_signup(@group, @church_rep, @gc).deliver_now
          UserMailer.welcome_church_rep(@church_rep).deliver_now
          @token = @gc.get_reset_password_token
          UserMailer.gc_nomination(@gc, @group, @church_rep, @token).deliver_now
  
#          @group.mysyg_enabled = @settings.mysyg_default_enabled
#          @group.mysyg_open = @settings.mysyg_default_open
#          @group.save
  
          flash[:notice] = "Thank you for registering your group. You are signed in as #{@church_rep.name}. Please set your password."
          bypass_sign_in @church_rep
          session["current_role"] = "church_rep"
          format.html { redirect_to edit_password_gc_user_path(@church_rep) }
        else
          flash[:notice] = "There was a problem with your signup. Please see the errors below"
          @groups = Group.order(:name).load
          format.html { render action: "new" }
        end
      end
    end
  end
  