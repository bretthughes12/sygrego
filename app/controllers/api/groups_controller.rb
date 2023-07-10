class Api::GroupsController < ApiController
    
    # GET /api/groups/1.xml
    def show
      @group = Group.find(params[:id])
      
      respond_to do |format|
        format.xml  { render xml: @group }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.xml { render xml: "<group></group>", status: :not_found }
      end
    end
end
