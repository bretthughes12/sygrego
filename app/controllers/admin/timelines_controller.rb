class Admin::TimelinesController < ApplicationController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'admin'
    
    # GET /admin/timelines
    def index
      @timelines = Timeline.order(:key_date, :name).load

      respond_to do |format|
        format.html # index.html.erb
      end
    end
  
    # GET /admin/timelines/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/timelines/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/timelines/1/edit
    def edit
    end
  
    # POST /admin/timeline
    def create
      respond_to do |format|
        if @timeline.save
          flash[:notice] = 'Timeline was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/timelines/1
    def update
      respond_to do |format|
        if @timeline.update(timeline_params)
          flash[:notice] = 'Timeline was successfully updated.'
          format.html { redirect_to admin_timelines_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/timelines/1
    def destroy
      @timeline.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_timelines_url }
      end
    end

    private
    
    def timeline_params
      params.require(:timeline).permit(:name, 
                                   :description,
                                   :key_date)
    end
end
