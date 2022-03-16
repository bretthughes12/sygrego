class MysygController < ApplicationController

    before_filter :find_group
    before_filter :find_participant
  
  private
    
    def find_group
      if params[:group]
        ms = MysygSetting.find_by_mysyg_name(params[:group])
        @group = ms.group unless ms.nil?
      elsif session["current_group"]
        @group = Group.find_by_abbr(session["current_group"])
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