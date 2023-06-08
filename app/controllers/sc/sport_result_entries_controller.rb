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
        sre.update(sport_result_entry_params(id))
        @sport_result_entries << sre unless sre.errors.empty?
      end
  
      if @sport_result_entries.empty?
        flash[:notice] = "Updated"
        redirect_to sc_sport_result_url(@section.id)
      else
        render :action => "index"  
      end
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