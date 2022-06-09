class Admin::SportsEvaluationsController < ApplicationController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'admin'
    
    # GET /admin/sports_evaluations
    def index
      @sports_evaluations = SportsEvaluation.order(:section).load

      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "sports_evaluations", "sports_evaluations" }
      end
    end
  
    # GET /admin/sports_evaluations/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/sports_evaluations/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/sports_evaluations/1/edit
    def edit
    end
  
    # POST /admin/sports_evaluations
    def create
      @sports_evaluation = SportsEvaluation.new(sports_evaluation_params)

      respond_to do |format|
        if @sports_evaluation.save
          flash[:notice] = 'Evaluation was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/sports_evaluations/1
    def update
      respond_to do |format|
        if @sports_evaluation.update(sports_evaluation_params)
          flash[:notice] = 'Evaluation was successfully updated.'
          format.html { redirect_to admin_sports_evaluations_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/sports_evaluations/1
    def destroy
      flash[:notice] = 'Evaluation deleted.'
      @sports_evaluation.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_sports_evaluations_url }
      end
    end
  
    private
    
    def sports_evaluation_params
      params.require(:sports_evaluation).permit(
        :sport, 
        :section, 
        :session,
        :venue_rating,
        :equipment_rating,
        :length_rating,
        :scoring_rating,
        :umpiring_rating,
        :time_rating,
        :support_rating,
        :safety_rating,
        :results_rating,
        :worked_well,
        :to_improve,
        :suggestions
      )
    end
  end
  