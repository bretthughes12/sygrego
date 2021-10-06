class Gc::InfoController < ApplicationController
    before_action :authenticate_user!

    layout 'gc'

    # GET /gc/info/home
    def home
        group_id = Group.all.first.id
        @group = Group.find(group_id)
    
        @total_groups = Group.coming.count
    end
end
