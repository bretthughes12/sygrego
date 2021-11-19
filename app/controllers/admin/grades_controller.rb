class Admin::GradesController < ApplicationController
    require 'csv'

    load_and_authorize_resource except: [:index]
    before_action :authenticate_user!
    
    layout "admin"
  
    # GET /admin/grades
    def index
      @grades = Grade.
        order(:name).
        includes(:sections).load
      authorize! :show, @grades

      respond_to do |format|
        format.html { @grades = @grades.paginate(page: params[:page], per_page: 50) }
        format.csv  { render_csv "sport_grade", "sport_grade" }
      end
    end
  
    # GET /admin/grades/1
    def show
    end
  
    # GET /admin/grades/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/grades/1/edit
    def edit
    end
  
    # POST /admin/grades
    def create
        @grade = Grade.new(grade_params)
        @grade.updated_by = current_user.id

        respond_to do |format|
            if @grade.save
                flash[:notice] = 'Grade was successfully created.'
                format.html { render action: "edit" }
            else
                format.html { render action: "new" }
            end
        end
    end
  
    # PUT /admin/grades/1
    def update
      @grade.updated_by = current_user.id

      respond_to do |format|
        if @grade.update(grade_params)
          flash[:notice] = 'Grade was successfully updated.'
          format.html { redirect_to admin_grades_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/grades/1
    def destroy
        @grade.updated_by = current_user.id

        if @grade.sections.empty?
            @grade.destroy
  
            respond_to do |format|
                format.html { redirect_to admin_grades_url }
            end
        
          else
            flash[:notice] = "Can't delete, as sections exist"
        
            respond_to do |format|
                format.html { redirect_to admin_grades_url }
            end
        end
    end
  
    # GET /admin/grades/new_import
    def new_import
      @grade = Grade.new
    end
  
    # POST /admin/grades/import
    def import
      if params[:grade] && params[:grade][:file].path =~ %r{\.csv$}i
        result = Grade.import(params[:grade][:file], current_user)

        flash[:notice] = "Grades upload complete: #{result[:creates]} grades created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_grades_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
        @grade = Grade.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end

private
  
    def grade_params
      params.require(:grade).permit(:name, 
                                    :active,
                                    :sport_id,
                                    :grade_type,
                                    :gender_type,
                                    :max_age,
                                    :min_age,
                                    :max_participants,
                                    :min_participants,
                                    :min_males,
                                    :min_females,
                                    :status,
                                    :entry_limit,
                                    :starting_entry_limit,
                                    :team_size)
    end
end
