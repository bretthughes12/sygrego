class Api::GradesController < ApplicationController
    before_action :authenticate_user!
    
    # GET /api/grades/1.xml
    def show
      @grade = Grade.find(params[:id])
      
      respond_to do |format|
        format.html { authorize! :show, @grade }
        format.xml  { render xml: @grade }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.html { raise }
        format.xml { render xml: "<grade></grade>", status: :not_found }
      end
    end
end