class Api::GroupsController < ApplicationController
    before_action :authorize_xml
    before_action :authenticate_user!
    
    # GET /api/groups/1.xml
    def show
      @group = Group.find(params[:id])
      
      respond_to do |format|
        format.html { authorize! :show, @group }
        format.xml  { render xml: @group }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.html { raise }
        format.xml { render xml: "<group></group>", status: :not_found }
      end
    end
end
