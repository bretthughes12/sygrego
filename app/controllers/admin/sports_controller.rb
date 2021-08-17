class Admin::SportsController < ApplicationController
#    require 'csv'

#    before_filter :authorize_if_remote
#    load_and_authorize_resource except: [:show]
  
#    layout "sports"
  
    # GET /admin/sports
    # GET /admin/sports.xml
    def index
#      page_sym = save_page("Sport", params)
#      session[page_sym] = params[:page].to_i if params[:page]
  
        @sports = Sport.order(:name).all
  
#      respond_to do |format|
#        format.html { @sports = @sports.paginate(page: session[page_sym]) }
#        format.xml  { render xml: @sports }
#        format.csv  do
#          if params[:option] == "download"
#            render_csv "sport", "sport" 
#          else
#            render_csv "sport_checklist" 
#          end
#        end
#      end
    end
  
    # GET /sports/1
    # GET /sports/1.xml
    # 'show' must be explicitly invoked from the address bar - it is not available from the UI
    def show
        @sport = Sport.find(params[:id])
#      authorize! :show, @sport
      
#      respond_to do |format|
#        format.html # show.html.erb
#        format.xml  { render xml: @sport }
#      end
        
#    rescue ActiveRecord::RecordNotFound 
#      respond_to do |format|
#        format.html { raise }
#        format.xml { render xml: "<sport></sport>", status: :not_found }
#      end
    end
  
    # GET /sports/new
    # GET /sports/new.xml
    def new
 #     @sport.max_indiv_entries_group = 0
        @sport = Sport.new

#      respond_to do |format|
#        format.html # new.html.erb
#        format.xml  { render xml: @sport }
#      end
    end
  
    # GET /sports/1/edit
    def edit
        @sport = Sport.find(params[:id])
    end
  
    # POST /sports
    # POST /sports.xml
    def create
        @sport = Sport.new(sport_params)

        respond_to do |format|
            if @sport.save
#               log(@sport, "CREATE")
                flash[:notice] = 'Sport was successfully created.'
                format.html { render action: "edit" }
#               format.xml  { render xml: @sport, status: :created }
            else
                format.html { render action: "new" }
#               format.xml  { render xml: @sport.errors, status: :unprocessable_entity }
            end
        end
    end
  
    # PUT /sports/1
    # PUT /sports/1.xml
    def update
        @sport = Sport.find(params[:id])

        begin
            respond_to do |format|
                if @sport.update(sport_params)
#                    log(@sport, "UPDATE")
                    flash[:notice] = 'Sport was successfully updated.'
                    format.html { redirect_to(admin_sports_url) }
#                    format.xml  { head :ok }
                else
                    format.html { render action: "edit" }
#                    format.xml  { render xml: @sport.errors, status: :unprocessable_entity }
                end
            end
  
        rescue ActiveRecord::StaleObjectError
            @sport = Sport.find(params[:id])
            flash[:notice] = 'Somebody else has updated this sport. Please check your changes and update again.'
  
            respond_to do |format|
                format.html { render action: "edit" }
#                format.xml  { render xml: @sport, status: :conflict }
            end
        end
    end
  
    # DELETE /sports/1
    # DELETE /sports/1.xml
    def destroy
        @sport = Sport.find(params[:id])

        begin
            @sport.destroy
#            log(@sport, "DESTROY")
  
            respond_to do |format|
                format.html { redirect_to(admin_sports_url) }
#                format.xml  { head :ok }
            end
        
        rescue Exception
            flash[:notice] = "Can't delete, as grades exist"
        
            respond_to do |format|
                format.html { redirect_to(admin_sports_url) }
#                format.xml  { head :failure }
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
