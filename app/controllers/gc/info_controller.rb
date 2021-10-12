class Gc::InfoController < ApplicationController
    before_action :authenticate_user!
    before_action :find_group

    layout 'gc'

    # GET /gc/info/home
    def home
        @total_groups = Group.coming.count
    end

    private
  
    def find_group
      if session["current_group"]
        @group = Group.find_by_abbr(session["current_group"])
      elsif current_user.groups.count > 0
        @group = current_user.groups.first
      else
        @group = Group.first
      end
    end
end
