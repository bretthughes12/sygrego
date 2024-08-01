class Gc::SportEntriesController < GcController
    load_and_authorize_resource
  
    # GET /gc/sport_entries
    def index
      if params[:order] == 'session'
        @sport_entries = @group.sport_entries.includes(:grade, section: :session).
          order('sessions.database_rowid, grades.name, sport_entries.status').load
      else
        @sport_entries = @group.sport_entries.includes(:grade).
          order('grades.name, sport_entries.status').load
      end
      
      respond_to do |format|
        format.html do
          @sport_entries = @sport_entries.paginate(page: params[:page], per_page: 100)
          render layout: @current_role.name
        end
        format.xlsx { render xlsx: "sport_entries", filename: "sport_entries.xlsx" }
      end
    end
  
    # GET /gc/sport_entries/sports_draws
    def sports_draws
      @sport_entries = @group.sport_entries.includes(:grade).
        order('grades.name, sport_entries.status').load
  
      respond_to do |format|
        format.html do
          @sport_entries = @sport_entries.paginate(page: params[:page], per_page: 100)
          render layout: @current_role.name
        end
      end
    end
  
    # GET /gc/sport_entries/sports_rules
    def sports_rules
      @sports = @group.sports
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end
    
    # GET /gc/sport_entries/1
    def show
      render layout: @current_role.name
    end
  
    # GET /gc/sport_entries/new
    def new
      @grades = @group.grades_available(false)
      @sections = @group.sections_available

      respond_to do |format|
        format.html { render layout: @current_role.name }
      end
    end
  
    # GET /gc/sport_entries/1/edit
    def edit
      render_for_edit
    end
  
    # POST /gc/sport_entries
    def create
      @sport_entry = SportEntry.new(sport_entry_params)
      @sport_entry.group_id = @group.id
      @sport_entry.updated_by = current_user.id

      if params[:sport_entry][:section_id]
        @section = @sport_entry.section
        if @section
          @sport_entry.grade = @section.grade
          @sport_entry.status = @section.grade.starting_status
        end
      end

      if params[:sport_entry][:grade_id]
        @grade = @sport_entry.grade
        if @grade
          @sport_entry.status = @grade.starting_status
          @sport_entry.section = @grade.starting_section
        end
      end
  
      if params[:participant_id]
        participant = Participant.find(params[:participant_id])
        @sport_entry.participants << participant
      end
  
      respond_to do |format|
        if @sport_entry.save
          flash[:notice] = 'Sport entry was successfully created.'
  
          if params[:return] && params[:return] == 'edit_sports'
            format.html { redirect_to(edit_sports_gc_participant_path(participant)) }
          else
            format.html { redirect_to(edit_gc_sport_entry_url(@sport_entry)) }
          end
        else
          if params[:return] && params[:return] == 'edit_sports'
            format.html { redirect_to(edit_sports_gc_participant_path(participant)) }
          else
            format.html { redirect_to action: "new" }
          end
        end
      end
    end

    # PATCH /gc/sport_entries/1
    def update
      @sport_entry.updated_by = current_user.id

      respond_to do |format|
        if @sport_entry.update(sport_entry_params)
          flash[:notice] = 'Details were successfully updated.'

          format.html { redirect_to gc_sport_entries_url }
        else
          format.html { render_for_edit } 
        end
      end
    end
  
    # PATCH /gc/sport_entries/1/confirm
    def confirm
      @sport_entry.updated_by = current_user.id
      @sport_entry.enter!

      respond_to do |format|
        flash[:notice] = 'Sport entry confirmed.'

        format.html { redirect_to gc_sport_entries_url }
      end
    end
  
    # DELETE /gc/sport_entries/1
    def destroy
      @sport_entry.updated_by = current_user.id
      @grade = @sport_entry.grade

      @sport_entry.destroy

      respond_to do |format|
        format.html { redirect_to gc_sport_entries_url }
      end
    end

    private
  
    def render_for_edit
      @participant = Participant.new
      @sections = @sport_entry.grade.sections
      @participants = @sport_entry.participants
            
      if @sport_entry.participants.size < @sport_entry.grade.max_participants
        @eligible_participants = @group.sports_participants_for_grade(@sport_entry.grade) - @sport_entry.participants
      else
        @eligible_participants = []
      end

      render action: "edit", layout: @current_role.name
    end

    def sport_entry_params
      params.require(:sport_entry).permit(
        :captaincy_id, 
        :grade_id,
        :section_id,
        :preferred_section_id
      )
    end
end
