class Admin::SportEntriesController < ApplicationController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout "admin"
  
    # GET /admin/sport_entries
    def index
      @sport_entries = SportEntry.all
  
      respond_to do |format|
        format.html { @sport_entries = @sport_entries.paginate(page: params[:page], per_page: 100) }
        format.csv  { render_csv "sport_entries", "sport_entries" }
      end
    end

    # GET /admin/sport_entries/1
    def show
    end
  
    # GET /admin/sport_entries/new
    def new
      @grades = Grade.all
      @groups = Group.coming.all
    end
  
    # GET /admin/sport_entries/1/edit
    def edit
      render_for_edit
    end
  
    # POST /admin/sport_entries
    def create
      @sport_entry = SportEntry.new(sport_entry_params)
      @sport_entry.updated_by = current_user.id

      @grade = @sport_entry.grade
      if @grade
        @sport_entry.status = @grade.starting_status
        @sport_entry.section = @grade.starting_section
      end
  
      respond_to do |format|
        if @sport_entry.save
          flash[:notice] = 'Sport entry was successfully created.'
          format.html { render_for_edit }
        else
          @grades = Grade.all
          @groups = Group.coming.all
          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/sport_entries/1
    def update
      @sport_entry.updated_by = current_user.id

      respond_to do |format|
        if @sport_entry.update(sport_entry_params)
          flash[:notice] = 'Sport entry was successfully updated.'

          format.html { redirect_to admin_sport_entries_url }
        else
          format.html { render_for_edit }
        end
      end
    end
  
    # DELETE /admin/sport_entries/1
    def destroy
        @sport_entry.updated_by = current_user.id

        @sport_entry.destroy
  
        respond_to do |format|
          format.html { redirect_to admin_sport_entries_url }
        end
    end
  
    # GET /admin/sport_entries/new_import
    def new_import
      @sport_entry = SportEntry.new
    end
  
    # POST /admin/sport_entries/import
    def import
      if params[:sport_entry] && params[:sport_entry][:file].path =~ %r{\.csv$}i
        result = SportEntry.import(params[:sport_entry][:file], current_user)

        flash[:notice] = "Sport entries upload complete: #{result[:creates]} sport_entries created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_sport_entries_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
        @sport_entry = SportEntry.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end

private

    def render_for_edit
      @participant = Participant.new
      @sections = @sport_entry.grade.sections
      @participants = @sport_entry.participants
            
      if @sport_entry.participants.size < @sport_entry.grade.max_participants
        @eligible_participants = @sport_entry.group.sports_participants_for_grade(@sport_entry.grade) - @sport_entry.participants
      else
        @eligible_participants = []
      end

      render action: "edit", layout: @current_role.name
    end

    def sport_entry_params
      params.require(:sport_entry).permit(
        :group_id, 
        :captaincy_id, 
        :grade_id,
        :section_id,
        :status,
        :preferred_section_id
      )
    end
end
