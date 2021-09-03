class Admin::SportsController < ApplicationController
    require 'csv'

#    before_filter :authorize_if_remote
    load_and_authorize_resource
    before_action :authenticate_user!
  
    layout "admin"
  
    # GET /admin/sports
    def index
#       page_sym = save_page("Sport", params)
#       session[page_sym] = params[:page].to_i if params[:page]
  
        @sports = Sport.order(:name).all
  
        respond_to do |format|
            format.html {  }
#           format.html { @sports = @sports.paginate(page: session[page_sym]) }
            format.csv  { render_csv "sport", "sport" }
        end
    end
  
    # GET /admin/sports/1
    # GET /admin/sports/1.xml
    # 'show' must be explicitly invoked from the address bar - it is not available from the UI
    def show
#        @sport = Sport.find(params[:id])
#        authorize! :show, @sport
      
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render xml: @sport }
        end
        
    rescue ActiveRecord::RecordNotFound 
        respond_to do |format|
            format.html { raise }
            format.xml { render xml: "<sport></sport>", status: :not_found }
        end
    end
  
    # GET /admin/sports/new
    def new
        @sport = Sport.new

        respond_to do |format|
            format.html # new.html.erb
        end
    end
  
    # GET /sports/1/edit
    def edit
#        @sport = Sport.find(params[:id])
    end
  
    # POST /admin/sports
    def create
        @sport = Sport.new(sport_params)
        @sport.updated_by = current_user.id

        respond_to do |format|
            if @sport.save
                flash[:notice] = 'Sport was successfully created.'
                format.html { render action: "edit" }
            else
                format.html { render action: "new" }
            end
        end
    end
  
    # PUT /admin/sports/1
    def update
#        @sport = Sport.find(params[:id])
        @sport.updated_by = current_user.id

        begin
            respond_to do |format|
                if @sport.update(sport_params)
                    flash[:notice] = 'Sport was successfully updated.'
                    format.html { redirect_to(admin_sports_url) }
                else
                    format.html { render action: "edit" }
                end
            end
  
        rescue ActiveRecord::StaleObjectError
            @sport = Sport.find(params[:id])
            flash[:notice] = 'Somebody else has updated this sport. Please check your changes and update again.'
  
            respond_to do |format|
                format.html { render action: "edit" }
            end
        end
    end
  
    # DELETE /admin/sports/1
    def destroy
#        @sport = Sport.find(params[:id])
        @sport.updated_by = current_user.id

        begin
            @sport.destroy
  
            respond_to do |format|
                format.html { redirect_to(admin_sports_url) }
            end
        
        rescue Exception
            flash[:notice] = "Can't delete, as grades exist"
        
            respond_to do |format|
                format.html { redirect_to(admin_sports_url) }
            end
        end
    end
  
  private
  
    def sport_params
      params.require(:sport).permit(:name, 
                                    :lock_version,
                                    :max_indiv_entries_group, 
                                    :max_team_entries_group, 
                                    :max_entries_indiv, 
                                    :classification,
                                    :active,
                                    :bonus_for_officials,
                                    :court_name,
                                    :draw_type)
    end
  end
