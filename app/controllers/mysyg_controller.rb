class MysygController < ApplicationController

  before_action :find_participant
  before_action :find_group
  before_action :authorize_participant_access
  
  private
    
  def authorize_participant_access
    if current_user 
        unless current_user.role?(:participant) || current_user.role?(:admin)
            flash[:notice] = "You are not authorised to perform the requested function"
            redirect_to home_url(current_user)
        end
    else
        flash[:notice] = "Please log in"
        redirect_to new_user_session_url
    end
  end

  def find_group
    if params[:group]
      ms = MysygSetting.find_by_mysyg_name(params[:group])
      @group = ms.group unless ms.nil?
    elsif session["current_group"]
      @group = Group.find_by_id(session["current_group"])
    end

    if @group.nil? && @participant
      @group = @participant.group
    end
    
    unless @group
      raise ActiveRecord::RecordNotFound.new('Could not find your group. Please check the link with your group coordinator.')
    end
  end
  
  def find_participant
    if session["current_participant"]
      @participant = Participant.where(id: session["current_participant"]).first
    elsif current_user && !current_user.participants.empty?
      @participant = Participant.where(id: current_user.participants.first.id).first
    end
  end
end