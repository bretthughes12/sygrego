class GcController < ApplicationController
  before_action :find_group
  before_action :authorize_gc_access
  
  layout "gc" 

  private
    
  def authorize_gc_access
    if current_user 
        unless current_role && (current_role.name == 'gc' || current_role.name == 'church_rep')
            flash[:notice] = "You are not authorised to perform the requested function"
            redirect_to home_url(current_user)
        end
    else
        flash[:notice] = "Please log in"
        sign_out
        redirect_to new_user_session_url
    end
  end
end