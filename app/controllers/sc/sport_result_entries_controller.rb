class Sc::SportResultEntriesController < ApplicationController
    before_action :set_sport_result_entry, only: %i[ show edit update destroy ]

    layout "sc"

    # GET /sc/sport_result_entries or /sc/sport_result_entries.json
    def index
      @sport_result_entries = SportResultEntry.all
    end
  
    # GET /sc/sport_result_entries/1 or /sc/sport_result_entries/1.json
    def show
    end
  
    # GET /sc/sport_result_entries/new
    def new
      @sport_result_entry = SportResultEntry.new
    end
  
    # GET /sc/sport_result_entries/1/edit
    def edit
    end
  
    # POST /sc/sport_result_entries or /sc/sport_result_entries.json
    def create
      @sport_result_entry = SportResultEntry.new(sport_result_entry_params)
  
      respond_to do |format|
        if @sport_result_entry.save
          format.html { redirect_to sc_sport_result_entry_url(@sport_result_entry), notice: "Sport result entry was successfully created." }
          format.json { render :show, status: :created, location: @sport_result_entry }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @sport_result_entry.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /sc/sport_result_entries/1 or /sc/sport_result_entries/1.json
    def update
      respond_to do |format|
        if @sport_result_entry.update(sport_result_entry_params)
          format.html { redirect_to sc_sport_result_entry_url(@sport_result_entry), notice: "Sport result entry was successfully updated." }
          format.json { render :show, status: :ok, location: @sport_result_entry }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @sport_result_entry.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /sc/sport_result_entries/1 or /sc/sport_result_entries/1.json
    def destroy
      @sport_result_entry.destroy
  
      respond_to do |format|
        format.html { redirect_to sc_sport_result_entries_url, notice: "Sport result entry was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  
    # PATCH sc/sport_result_entries/update_multiple
    def update_multiple
      @sport_result_entries = []
      @section = Section.find(params[:section_id])
      
      params[:sport_result_entries].keys.each do |id|
        sre = SportResultEntry.find(id.to_i)

        if params[:sport_result_entries][id][:score_a] == 'Forfeit' && params[:sport_result_entries][id][:score_b] == 'Forfeit'
          sre.forfeit_a = true
          sre.forfeit_b = true
          sre.complete = true
        elsif params[:sport_result_entries][id][:score_a] == 'Forfeit'
          sre.forfeit_a = true
          sre.forfeit_b = false
          sre.complete = true
          params[:sport_result_entries][id][:score_b] = sre.forfeit_score
        elsif params[:sport_result_entries][id][:score_b] == 'Forfeit'
          sre.forfeit_b = true
          sre.forfeit_a = false
          sre.complete = true
          params[:sport_result_entries][id][:score_a] = sre.forfeit_score
        elsif params[:sport_result_entries][id][:score_a] == '0' && params[:sport_result_entries][id][:score_b] == '0'
          sre.forfeit_b = false
          sre.forfeit_a = false
          sre.complete = false
        else
          sre.complete = true
        end

        sre.update(sport_result_entry_params(id))
        @sport_result_entries << sre unless sre.errors.empty?
      end
  
      if @sport_result_entries.empty?
        flash[:notice] = "Updated"
        redirect_to sc_sport_result_url(@section.id)
      else
        render action: :show, controller: "sport_results"  
      end
    end
  
    # GET sc/sport_result_entries/reset
    def reset
      @sport_result_entries = []
      @section = Section.find(params[:section_id])
      
      @section.sport_result_entries.all.each do |sre|
        if sre.match > 99
          sre.delete
        else 
          sre.score_a = 0
          sre.forfeit_a = false
          sre.score_b = 0
          sre.forfeit_b = false
          sre.complete = false
          sre.save(validate: false)
        end
      end

      flash[:notice] = "Results reset"
      redirect_to sc_sport_result_url(@section.id)
    end
  
    # GET sc/sport_result_entries/submit
    def submit
      @sport_result_entries = []
      @section = Section.find(params[:section_id])

      final = @section.sport_result_entries.order(:match).last 

      if final.match == 200 && final.complete
        @section.results_locked = true
        @section.save(validate: false)

        SportResultMailer.draw_submitted(@section).deliver_now
        
        flash[:notice] = "Results submitted, thank you!"
        redirect_to sc_sport_results_path
      else
        flash[:notice] = "Results not completed"
        redirect_to sc_sport_result_url(@section.id)
      end
    end
  
    # GET sc/sport_result_entries/calculate_finalists
    def calculate_finalists
      @sport_result_entries = []
      @section = Section.find(params[:section_id])

      # initial finals (semis or final depending on finals format)
      if @section.sport_result_entries.maximum(:match) < 100
        ladder = RoundRobinLadder.new
        ladder.add_sports_entries(@section.sport_entries)
        
        @section.sport_result_entries.where('match < 100').load.each do |sre|
          ladder.add_result(sre)
        end

        add_finals_from_ladder(ladder)

      elsif @section.sport_result_entries.maximum(:match) < 200
        add_finalists_from_semis(@section)
      end

      flash[:notice] = "Finalists calculated"
      redirect_to sc_sport_result_url(@section.id)
    end
    
    private

    def add_finals_from_ladder(ladder)
      # 1 v 2 straight to grand final (only 1 group)
      if ladder.finals_format == 'Top 2'
        SportResultEntry.create(
          section_id: ladder.section_id,
          court: ladder.start_court,
          match: 200,
          entry_a_id: ladder.nth_in_group(1, 1),
          entry_b_id: ladder.nth_in_group(1, 2)
        )
      # 1 v 4 and 2 v 3 to semi finals (only 1 group)
      elsif ladder.finals_format == 'Top 4'
        SportResultEntry.create(
          section_id: ladder.section_id,
          court: ladder.start_court,
          match: 100,
          entry_a_id: ladder.nth_in_group(1, 1),
          entry_b_id: ladder.nth_in_group(1, 4)
        )
        SportResultEntry.create(
          section_id: ladder.section_id,
          court: ladder.start_court + 1,
          match: 101,
          entry_a_id: ladder.nth_in_group(1, 2),
          entry_b_id: ladder.nth_in_group(1, 3)
        )
      # 1 v 2 of opposing groups to semi finals (2 groups)
      elsif ladder.finals_format == 'Top 2 in Group'
        SportResultEntry.create(
          section_id: ladder.section_id,
          court: ladder.start_court,
          match: 100,
          entry_a_id: ladder.nth_in_group(1, 1),
          entry_b_id: ladder.nth_in_group(2, 2)
        )
        SportResultEntry.create(
          section_id: ladder.section_id,
          court: ladder.start_court + 1,
          match: 101,
          entry_a_id: ladder.nth_in_group(2, 1),
          entry_b_id: ladder.nth_in_group(1, 2)
        )
      elsif ladder.finals_format == 'Top in Group' && ladder.groups == 3
        # Top from each group, and next best (3 groups)
        SportResultEntry.create(
          section_id: ladder.section_id,
          court: ladder.start_court,
          match: 100,
          entry_a_id: ladder.nth_in_group(1, 1),
          entry_b_id: ladder.nth_in_group(2, 1)
        )
        SportResultEntry.create(
          section_id: ladder.section_id,
          court: ladder.start_court + 1,
          match: 101,
          entry_a_id: ladder.nth_in_group(3, 1),
          entry_b_id: ladder.next_best
        )
      else # ladder.finals_format == 'Top in Group' && ladder.groups == 4
        # Top from each group (4 groups)
        SportResultEntry.create(
          section_id: ladder.section_id,
          court: ladder.start_court,
          match: 100,
          entry_a_id: ladder.nth_in_group(1, 1),
          entry_b_id: ladder.nth_in_group(2, 1)
        )
        SportResultEntry.create(
          section_id: ladder.section_id,
          court: ladder.start_court + 1,
          match: 101,
          entry_a_id: ladder.nth_in_group(3, 1),
          entry_b_id: ladder.nth_in_group(4, 1)
        )
      end
    end

    def add_finalists_from_semis(section)
      # winners of each semi play in finals
      s1 = section.sport_result_entries.where(match: 100).first
      s2 = section.sport_result_entries.where(match: 101).first

      if s1.score_a > s1.score_b
        w1 = s1.entry_a_id
      else
        w1 = s1.entry_b_id
      end

      if s2.score_a > s2.score_b
        w2 = s2.entry_a_id
      else
        w2 = s2.entry_b_id
      end

      # TODO: change hard-coded start court
      SportResultEntry.create(
        section_id: section.id,
        court: 1,
        match: 200,
        entry_a_id: w1,
        entry_b_id: w2
      )
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_sport_result_entry
      @sport_result_entry = SportResultEntry.find(params[:id])
    end
  
      # Only allow a list of trusted parameters through.
    def sport_result_entry_params(id)
      params.require(:sport_result_entries)
            .fetch(id)
            .permit(:complete,
                    :entry_a_id,
                    :entry_b_id,
                    :score_a,
                    :score_b)
    end
  end