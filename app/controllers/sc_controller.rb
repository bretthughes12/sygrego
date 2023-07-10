class ScController < ApplicationController
  before_action :authorize_sc_access
  
  layout 'sc'

  private
    
  def authorize_sc_access
    if current_user 
        unless current_role.name == 'sc'
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