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
      
      flash[:notice] = "Finalists calculated"
      redirect_to sc_sport_result_url(@section.id)
    end
    
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sport_result_entry
        @sport_result_entry = SportResultEntry.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def sport_result_entry_params(id)
        params.require(:sport_result_entries)
              .fetch(id)
              .permit(:complete,
                      :score_a,
                      :score_b)
      end
  end