class Sc::SportsEvaluationsController < ScController

  load_and_authorize_resource
  
  # GET /sc/sports_evaluations/new
  def new
    @sports_evaluation = SportsEvaluation.new

    respond_to do |format|
      format.html # new_good_sports.html.erb
    end
  end

  # POST /sc/sports_evaluations
  def create
    @sports_evaluation = SportsEvaluation.new(sports_evaluation_params)

    respond_to do |format|
      if @sports_evaluation.save
          flash[:notice] = 'Thanks for your evaluation. Another?'
          format.html do
            redirect_to new_sc_sports_evaluation_url
          end
      else
          format.html { render action: "new" }
      end
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