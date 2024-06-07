class Admin::SectionsController < AdminController
    require 'csv'

    load_and_authorize_resource 
    before_action :authenticate_user!
    
    # GET /admin/sections
    def index
      @sections = Section.
        order(:name).
        includes(:session, :venue).load
  
      respond_to do |format|
        format.html { @sections = @sections.paginate(page: params[:page], per_page: 50) }
        format.csv  { render_csv "sport_section", "sport_section" }
        format.xlsx { render xlsx: "index", filename: "sections.xlsx" }
      end
    end
  
    # GET /admin/sections/results
    def results
      @sections = Section.round_robin.order(:name).all
  
      respond_to do |format|
        format.html # index.html.erb
      end
    end
  
    # GET /admin/sections/1
    def show
    end
  
    # GET /admin/sections/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/sections/1/edit
    def edit
    end
  
    # POST /admin/sections
    def create
        @section = Section.new(section_params)
        @section.updated_by = current_user.id

        respond_to do |format|
            if @section.save
                flash[:notice] = 'Section was successfully created.'
                format.html { render action: "edit" }
            else
                format.html { render action: "new" }
            end
        end
    end
  
    # PATCH /admin/sections/1
    def update
      @section.updated_by = current_user.id

      respond_to do |format|
        if @section.update(section_params)
          flash[:notice] = 'Section was successfully updated.'
          format.html { redirect_to admin_sections_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/sections/1
    def destroy
        @section.updated_by = current_user.id

        @section.destroy
  
        respond_to do |format|
            format.html { redirect_to admin_sections_url }
        end
    end
  
    # PATCH /admin/sections/1/purge_file
    def purge_file
        @section.updated_by = current_user.id

        @section.draw_file.purge
  
        respond_to do |format|
            format.html { render action: "edit" }
        end
    end
  
    # PATCH /admin/volunteer/1/sections/add_section
    def add_section
      @volunteer = Volunteer.find(params[:volunteer_id])
      @section = Section.find(params[:section_id])

      @volunteer.sections << @section unless @volunteer.sections.include?(@section)

      respond_to do |format|
        format.html { redirect_to edit_admin_volunteer_url(@volunteer) }
      end
    end
  
    # DELETE /admin/volunteer/1/section/1/purge
    def purge
      @volunteer = Volunteer.find(params[:volunteer_id])

      @volunteer.sections.delete(@section)
  
      respond_to do |format|
        format.html { redirect_to edit_admin_volunteer_url(@volunteer) }
      end
    end

    # GET /admin/sections/new_import
    def new_import
      @section = Section.new
    end
  
    # POST /admin/sections/import
    def import
      if params[:section] && params[:section][:file].path =~ %r{\.xlsx$}i
        result = Section.import_excel(params[:section][:file], current_user)

        flash[:notice] = "Sections upload complete: #{result[:creates]} sections created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_sections_url }
        end
      else
        flash[:notice] = "Upload file must be in '.xlsx' format"
        @section = Section.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end

private
  
    def section_params
      params.require(:section).permit(:name, 
                                    :active,
                                    :grade_id,
                                    :venue_id,
                                    :session_id,
                                    :number_in_draw,
                                    :number_of_courts,
                                    :year_introduced,
                                    :draw_file,
                                    :draw_type,
                                    :finals_format,
                                    :number_of_groups,
                                    :start_court,
                                    :results_locked)
    end
end
