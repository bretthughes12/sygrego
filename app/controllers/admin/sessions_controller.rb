class Admin::SessionsController < ApplicationController
    require 'csv'

    load_and_authorize_resource except: [:show]
    before_action :authenticate_user!
    
    layout "admin"
  
    # GET /admin/sessions
    def index
      @sessions = Session.order(:id).load
  
      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "sport_session" }
      end
    end
  
    # GET /admin/sessions/1
    # GET /admin/sessions/1.xml
    # 'show' must be explicitly invoked from the address bar - it is not available from the UI
    def show
      @session = Session.find(params[:id])
      authorize! :show, @session
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render xml: @session }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.html { raise }
        format.xml { render xml: "<session></session>", status: :not_found }
      end
    end
  
    # GET /admin/sessions/new
    def new
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render xml: @session }
      end
    end
  
    # GET /admin/sessions/1/edit
    def edit
    end
  
    # POST /admin/sessions
    def create
        @session = Session.new(session_params)
        @session.updated_by = current_user.id

        respond_to do |format|
            if @session.save
                flash[:notice] = 'Session was successfully created.'
                format.html { render action: "edit" }
            else
                format.html { render action: "new" }
            end
        end
    end
  
    # PUT /admin/sessions/1
    def update
      @session.updated_by = current_user.id

      respond_to do |format|
        if @session.update(session_params)
          flash[:notice] = 'Session was successfully updated.'
          format.html { redirect_to admin_sessions_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/sessions/1
    def destroy
        @session.updated_by = current_user.id

        begin
            @session.destroy
  
            respond_to do |format|
                format.html { redirect_to admin_sessions_url }
            end
        
        rescue Exception
            flash[:notice] = "Can't delete, as grades are defined using this session"
        
            respond_to do |format|
                format.html { redirect_to admin_sessions_url }
            end
        end
    end
  
  private
  
    def session_params
      params.require(:session).permit(:name, 
                                      :active,
                                      :database_rowid)
    end
end
