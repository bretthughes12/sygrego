class Sc::RoundRobinMatchesController < ScController

  load_and_authorize_resource 
  before_action :authenticate_user!
  
  # GET /sc/sections/1/round_robin_mmatches
  def index
    @section = Section.find_by_id(params[:section_id])
    @round_robin_matches = RoundRobinMatch.where(section: @section.id).order(:court, :match).load
    @teams = @section.sport_entries
    @ladder = RoundRobinLadder.new(@section)

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # PATCH sc/sections/1/round_robin_matches/update_multiple
  def update_multiple
    @round_robin_matches = []
    @section = Section.find(params[:section_id])
    
    if params[:round_robin_matches]
      params[:round_robin_matches].keys.each do |id|
        sre = RoundRobinMatch.find(id.to_i)

        if params[:round_robin_matches][id][:score_a] == 'Forfeit' && params[:round_robin_matches][id][:score_b] == 'Forfeit'
          sre.forfeit_a = true
          sre.forfeit_b = true
          sre.complete = true
          params[:round_robin_matches][id][:score_a] = 0
          params[:round_robin_matches][id][:score_b] = 0
        elsif params[:round_robin_matches][id][:score_a] == 'Forfeit'
          sre.forfeit_a = true
          sre.forfeit_b = false
          sre.complete = true
          params[:round_robin_matches][id][:score_a] = 0
          params[:round_robin_matches][id][:score_b] = @section.sport.forfeit_score
        elsif params[:round_robin_matches][id][:score_b] == 'Forfeit'
          sre.forfeit_b = true
          sre.forfeit_a = false
          sre.complete = true
          params[:round_robin_matches][id][:score_b] = 0
          params[:round_robin_matches][id][:score_a] = @section.sport.forfeit_score
        elsif params[:commit] == "Calculate Finalists"
          sre.complete = true
        elsif params[:round_robin_matches][id][:score_a] == '0' && params[:round_robin_matches][id][:score_b] == '0'
          sre.forfeit_b = false
          sre.forfeit_a = false
          sre.complete = false
        else
          sre.complete = true
        end

        sre.update(round_robin_match_params(id))
        @round_robin_matches << sre unless sre.errors.empty?
      end
    end

    @ladder = RoundRobinLadder.new(@section)

    if @round_robin_matches.empty?
      if params[:commit] == "Calculate Finalists"
        # initial finals (semis or final depending on finals format)
        if @section.round_robin_matches.maximum(:match) < 100
          ladder = RoundRobinLadder.new(@section)

          @section.add_finals_from_ladder(ladder)

        elsif @section.round_robin_matches.maximum(:match) < 200
          @section.add_finalists_from_semis
        end

        flash[:notice] = "Finalists calculated"
        redirect_to sc_section_round_robin_matches_url(section_id: @section.id)

      elsif params[:commit] == "Submit"
        final = @section.round_robin_matches.order(:match).last 

        if final.match == 200 && final.complete
          @section.lock_results!

          RoundRobinMatchMailer.draw_submitted(@section).deliver_now
          
          flash[:notice] = "Results submitted, thank you!"
          redirect_to sc_sections_path
        else
          flash[:notice] = "Results not completed"
          redirect_to sc_section_round_robin_matches_url(section_id: @section.id)
        end
  
      else
        flash[:notice] = "Updated"
        redirect_to sc_section_round_robin_matches_url(section_id: @section.id)
      end
    end
  end

  # GET sc/sections/1/round_robin_matches/reset
  def reset
    @round_robin_matches = []
    @section = Section.find(params[:section_id])
    
    @section.reset_round_robin_draw!

    flash[:notice] = "Results reset"
    redirect_to sc_section_round_robin_matches_url(section_id: @section.id)
  end
    
  private

  # Only allow a list of trusted parameters through.
  def round_robin_match_params(id)
    params.require(:round_robin_matches)
          .fetch(id)
          .permit(:complete,
                  :entry_a_id,
                  :entry_b_id,
                  :score_a,
                  :score_b)
  end
end