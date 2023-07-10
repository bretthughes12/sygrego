class Admin::SessionsController < AdminController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
    
    # GET /admin/sessions
    def index
      @sessions = Session.order(:database_rowid).includes(:sections).load
  
      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "sport_session" }
      end
    end
  
    # GET /admin/sessions/1
    def show
    end
  
    # GET /admin/sessions/new
    def new
      respond_to do |format|
        format.html # new.html.erb
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
  
    # PATCH /admin/sessions/1
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

        if @session.sections.empty?
            @session.destroy
  
            respond_to do |format|
                format.html { redirect_to admin_sessions_url }
            end
        
          else
            flash[:notice] = "Can't delete, as sections exist"
        
            respond_to do |format|
                format.html { redirect_to admin_sessions_url }
            end
        end
    end
  
    # GET /admin/sessions/new_import
    def new_import
      @session = Session.new
    end
  
    # POST /admin/sessions/import
    def import
      if params[:session] && params[:session][:file].path =~ %r{\.csv$}i
        result = Session.import(params[:session][:file], current_user)

        flash[:notice] = "Sessions upload complete: #{result[:creates]} sessions created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_sessions_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
        @session = Session.new

        respond_to do |format|
          format.html { render action: "new_import" }
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
