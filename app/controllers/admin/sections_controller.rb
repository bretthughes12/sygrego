class Admin::SectionsController < ApplicationController
    require 'csv'

    load_and_authorize_resource except: [:show]
    before_action :authenticate_user!
    
    layout "admin"
  
    # GET /admin/sections
    def index
      @sections = Section.order(:name).load
  
      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "sport_section", "sport_section" }
      end
    end
  
    # GET /admin/sections/1
    # GET /admin/sections/1.xml
    # 'show' must be explicitly invoked from the address bar - it is not available from the UI
    def show
      @section = Section.find(params[:id])
      authorize! :show, @section
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render xml: @section }
      end
      
    rescue ActiveRecord::RecordNotFound 
      respond_to do |format|
        format.html { raise }
        format.xml { render xml: "<section></section>", status: :not_found }
      end
    end
  
    # GET /admin/sections/new
    def new
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render xml: @section }
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
  
    # PUT /admin/sections/1
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
  
    # GET /admin/sections/new_import
    def new_import
      @section = Section.new
    end
  
    # POST /admin/sections/import
    def import
      if params[:section][:file].path =~ %r{\.csv$}i
        result = Section.import(params[:section][:file], current_user)

        flash[:notice] = "Sections upload complete: #{result[:creates]} sections created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_sections_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
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
                                    :draw_file)
    end
end
