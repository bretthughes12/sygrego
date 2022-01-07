class Gc::SportEntriesController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    
    layout "gc" 
  
    # GET /gc/sport_entries
    def index
      @sport_entries = @group.sport_entries.all
  
      respond_to do |format|
        format.html do
          @sport_entries = @sport_entries.paginate(page: params[:page], per_page: 100)
          render layout: @current_role.name
        end
        format.csv  { render_csv "sport_entry", "sport_entry" }
      end
    end
    
    # GET /gc/sport_entries/1
    def show
      render layout: @current_role.name
    end
  
    # GET /gc/sport_entries/new
    def new
      @sports = @group.sports_available(false).sort
      @grades = @group.grades_available(false)

      respond_to do |format|
        format.html { render layout: @current_role.name }
      end
    end
  
    # GET /gc/sport_entries/1/edit
    def edit
      @participant = Participant.new
      @sections = @sport_entry.grade.sections
      @participants = @sport_entry.participants
    
      if @participants.size < @sport_entry.grade.max_participants
        @eligible_participants = @group.sports_participants_for_grade(@sport_entry.grade) - @sport_entry.participants
      else
        @eligible_participants = []
      end
  
      render layout: @current_role.name
    end
  
    # POST /gc/sport_entries
    def create
      @sport_entry = SportEntry.new(sport_entry_params)
      @sport_entry.group_id = @group.id
      @sport_entry.updated_by = current_user.id

      @grade = @sport_entry.grade
      if @grade
        @sport_entry.status = @grade.starting_status
        @sport_entry.section = @grade.starting_section
      end
  
      respond_to do |format|
        if @sport_entry.save
          flash[:notice] = 'Sport entry was successfully created.'

#          if !@settings.restricted_sports_allocated
#            Reg::SportEntriesController.delay.refresh_sport_entry_chances!(@group, @grade)
#          end
  
          format.html { redirect_to edit_gc_sport_entry_url(@sport_entry) }
        else
          format.html { redirect_to action: "new" }
        end
      end
    end

    # PUT /gc/sport_entries/1
    def update
      @sport_entry.updated_by = current_user.id

      respond_to do |format|
        if @sport_entry.update(sport_entry_params)
          flash[:notice] = 'Details were successfully updated.'

          format.html { redirect_to gc_sport_entries_url }
        else
          format.html do 
            @participant = Participant.new
            
            if @sport_entry.participants.size < @sport_entry.grade.max_participants
              @participants = @group.sports_participants_for_grade(@sport_entry.grade) - @sport_entry.participants
            else
              @participants = []
            end

            @sections = @sport_entry.grade.sections
            render action: "edit", layout: @current_role.name
          end
        end
      end
    end
  
    # DELETE /gc/sport_entries/1
    def destroy
      @sport_entry.updated_by = current_user.id
      @grade = @sport_entry.grade

      @sport_entry.destroy

#      if !@settings.restricted_sports_allocated
#        Reg::SportEntriesController.delay.refresh_sport_entry_chances!(@group, @grade)
#      end

      respond_to do |format|
        format.html { redirect_to gc_sport_entries_url }
      end
    end

    private
  
    def sport_entry_params
      params.require(:sport_entry).permit(
        :captaincy_id, 
        :grade_id,
        :preferred_section_id
      )
    end
end
