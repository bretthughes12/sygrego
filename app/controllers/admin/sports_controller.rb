class Admin::SportsController < AdminController

    load_and_authorize_resource
    before_action :authenticate_user!
  
    # GET /admin/sports
    def index
        @sports = Sport.order(:name).includes(:grades).all
  
        respond_to do |format|
            format.html {  }
            format.xlsx { render xlsx: "index", filename: "sports.xlsx" }
        end
    end
  
    # GET /admin/sports/1
    def show
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
  
    # PATCH /admin/sports/1
    def update
        @sport.updated_by = current_user.id

        respond_to do |format|
            if @sport.update(sport_params)
                flash[:notice] = 'Sport was successfully updated.'
                format.html { redirect_to(admin_sports_url) }
            else
                format.html { render action: "edit" }
            end
        end
    end
  
    # DELETE /admin/sports/1
    def destroy
        @sport.updated_by = current_user.id


        if @sport.grades.empty?
            @sport.destroy
  
            respond_to do |format|
                format.html { redirect_to(admin_sports_url) }
            end
        
        else
            flash[:notice] = "Can't delete, as grades exist"
        
            respond_to do |format|
                format.html { redirect_to admin_sports_url }
            end
        end
    end
  
    # PATCH /admin/sports/1/purge_file
    def purge_file
        @sport.updated_by = current_user.id

        @sport.rules_file.purge
  
        respond_to do |format|
            format.html { render action: "edit" }
        end
    end

    # GET /admin/sports/new_import
    def new_import
        @sport = Sport.new
    end
    
    # POST /admin/sports/import
    def import
        if params[:sport] && params[:sport][:file].path =~ %r{\.xlsx$}i
          result = Sport.import_excel(params[:sport][:file], current_user)
  
          flash[:notice] = "Sports upload complete: #{result[:creates]} sports created; #{result[:updates]} updates; #{result[:errors]} errors"
  
          respond_to do |format|
            format.html { redirect_to admin_sports_url }
          end
        else
          flash[:notice] = "Upload file must be in '.xlsx' format"
          @sport = Sport.new
  
          respond_to do |format|
            format.html { render action: "new_import" }
          end
        end
    end
    
  private
  
    def sport_params
      params.require(:sport).permit(:name, 
                                    :max_indiv_entries_group, 
                                    :max_team_entries_group, 
                                    :max_entries_indiv, 
                                    :classification,
                                    :active,
                                    :court_name,
                                    :point_name,
                                    :draw_type,
                                    :ladder_tie_break,
                                    :allow_negative_score,
                                    :blowout_rule,
                                    :forfeit_score,
                                    :rules_file)
    end
  end
