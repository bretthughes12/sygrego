class Admin::SportResultEntriesController < ApplicationController
    before_action :set_admin_sport_result_entry, only: %i[ show edit update destroy ]

    layout "admin"

    # GET /admin/sport_result_entries or /admin/sport_result_entries.json
    def index
      @admin_sport_result_entries = SportResultEntry.all
    end
  
    # GET /admin/sport_result_entries/1 or /admin/sport_result_entries/1.json
    def show
    end
  
    # GET /admin/sport_result_entries/new
    def new
      @admin_sport_result_entry = SportResultEntry.new
    end
  
    # GET /admin/sport_result_entries/1/edit
    def edit
    end
  
    # POST /admin/sport_result_entries or /admin/sport_result_entries.json
    def create
      @admin_sport_result_entry = SportResultEntry.new(admin_sport_result_entry_params)
  
      respond_to do |format|
        if @admin_sport_result_entry.save
          format.html { redirect_to admin_sport_result_entry_url(@admin_sport_result_entry), notice: "Sport result entry was successfully created." }
          format.json { render :show, status: :created, location: @admin_sport_result_entry }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @admin_sport_result_entry.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /admin/sport_result_entries/1 or /admin/sport_result_entries/1.json
    def update
      respond_to do |format|
        if @admin_sport_result_entry.update(admin_sport_result_entry_params)
          format.html { redirect_to admin_sport_result_entry_url(@admin_sport_result_entry), notice: "Sport result entry was successfully updated." }
          format.json { render :show, status: :ok, location: @admin_sport_result_entry }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @admin_sport_result_entry.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /admin/sport_result_entries/1 or /admin/sport_result_entries/1.json
    def destroy
      @admin_sport_result_entry.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_sport_result_entries_url, notice: "Sport result entry was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    # GET /admin/sport_result_entries/new_import
    def new_import
      @sport_result_entry = SportResultEntry.new
    end
  
    # POST /admin/sport_result_entries/import
    def import
      if params[:sport_result_entry] && params[:sport_result_entry][:file].path =~ %r{\.csv$}i
        result = SportResultEntry.import(params[:sport_result_entry][:file], current_user)

        flash[:notice] = "Sport Draws upload complete: #{result[:creates]} sports created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_sport_results_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
        @sport_result_entry = SportResultEntry.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_admin_sport_result_entry
        @admin_sport_result_entry = SportResultEntry.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def admin_sport_result_entry_params
        params.fetch(:admin_sport_result_entry, {})
      end
  end