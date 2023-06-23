class Sc::RoundRobinMatchesController < ApplicationController

  load_and_authorize_resource 
  before_action :authenticate_user!
  
  layout "sc"

  # GET /sc/sections/1/round_robin_mmatches
  def index
    @section = Section.find_by_id(params[:section_id])
    @round_robin_matches = RoundRobinMatch.where(section: @section.id).order(:court, :match).load
    @teams = @section.sport_entries

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # PATCH sc/sections/1/round_robin_matches/update_multiple
  def update_multiple
    @round_robin_matches = []
    @section = Section.find(params[:section_id])
    
    params[:round_robin_matches].keys.each do |id|
      sre = RoundRobinMatch.find(id.to_i)

      if params[:round_robin_matches][id][:score_a] == 'Forfeit' && params[:round_robin_matches][id][:score_b] == 'Forfeit'
        sre.forfeit_a = true
        sre.forfeit_b = true
        sre.complete = true
      elsif params[:round_robin_matches][id][:score_a] == 'Forfeit'
        sre.forfeit_a = true
        sre.forfeit_b = false
        sre.complete = true
        params[:round_robin_matches][id][:score_b] = sre.forfeit_score
      elsif params[:round_robin_matches][id][:score_b] == 'Forfeit'
        sre.forfeit_b = true
        sre.forfeit_a = false
        sre.complete = true
        params[:round_robin_matches][id][:score_a] = sre.forfeit_score
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

    if @round_robin_matches.empty?
      if params[:commit] == "Calculate Finalists"
        # initial finals (semis or final depending on finals format)
        if @section.round_robin_matches.maximum(:match) < 100
          ladder = RoundRobinLadder.new(@section)
          ladder.add_sports_entries(@section.sport_entries)
          
          @section.round_robin_matches.where('match < 100').load.each do |sre|
            ladder.add_result(sre)
          end

          add_finals_from_ladder(@section, ladder)

        elsif @section.round_robin_matches.maximum(:match) < 200
          add_finalists_from_semis(@section)
        end

        flash[:notice] = "Finalists calculated"
        redirect_to sc_section_round_robin_matches_url(section_id: @section.id)

      elsif params[:commit] == "Submit"
        final = @section.round_robin_matches.order(:match).last 

        if final.match == 200 && final.complete
          @section.results_locked = true
          @section.save(validate: false)

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
    else
      render action: :index  
    end
  end

  # GET sc/sections/1/round_robin_matches/reset
  def reset
    @round_robin_matches = []
    @section = Section.find(params[:section_id])
    
    @section.round_robin_matches.all.each do |sre|
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
    redirect_to sc_section_round_robin_matches_url(section_id: @section.id)
  end
    
  private

  def add_finals_from_ladder(section, ladder)
    # 1 v 2 straight to grand final (only 1 group)
    if section.finals_format == 'Top 2'
      RoundRobinMatch.create(
        section_id: section.id,
        court: ladder.start_court,
        match: 200,
        entry_a_id: ladder.nth_in_group(1, 1),
        entry_b_id: ladder.nth_in_group(1, 2)
      )
    # 1 v 4 and 2 v 3 to semi finals (only 1 group)
    elsif section.finals_format == 'Top 4'
      RoundRobinMatch.create(
        section_id: section.id,
        court: ladder.start_court,
        match: 100,
        entry_a_id: ladder.nth_in_group(1, 1),
        entry_b_id: ladder.nth_in_group(1, 4)
      )
      RoundRobinMatch.create(
        section_id: section.id,
        court: ladder.second_court,
        match: 101,
        entry_a_id: ladder.nth_in_group(1, 2),
        entry_b_id: ladder.nth_in_group(1, 3)
      )
    # 1 v 2 of opposing groups to semi finals (2 groups)
    elsif section.finals_format == 'Top 2 in Group'
      RoundRobinMatch.create(
        section_id: section.id,
        court: ladder.start_court,
        match: 100,
        entry_a_id: ladder.nth_in_group(1, 1),
        entry_b_id: ladder.nth_in_group(2, 2)
      )
      RoundRobinMatch.create(
        section_id: section.id,
        court: ladder.second_court,
        match: 101,
        entry_a_id: ladder.nth_in_group(2, 1),
        entry_b_id: ladder.nth_in_group(1, 2)
      )
    elsif section.finals_format == 'Top in Group' && section.number_of_groups == 3
      # Top from each group, and next best (3 groups)
      RoundRobinMatch.create(
        section_id: section.id,
        court: ladder.start_court,
        match: 100,
        entry_a_id: ladder.nth_in_group(1, 1),
        entry_b_id: ladder.nth_in_group(2, 1)
      )
      RoundRobinMatch.create(
        section_id: section.id,
        court: ladder.second_court,
        match: 101,
        entry_a_id: ladder.nth_in_group(3, 1),
        entry_b_id: ladder.next_best
      )
    else # section.finals_format == 'Top in Group' && section.number_of_groups == 4
      # Top from each group (4 groups)
      RoundRobinMatch.create(
        section_id: section.id,
        court: ladder.start_court,
        match: 100,
        entry_a_id: ladder.nth_in_group(1, 1),
        entry_b_id: ladder.nth_in_group(2, 1)
      )
      RoundRobinMatch.create(
        section_id: section.id,
        court: ladder.second_court,
        match: 101,
        entry_a_id: ladder.nth_in_group(3, 1),
        entry_b_id: ladder.nth_in_group(4, 1)
      )
    end
  end

  def add_finalists_from_semis(section)
    # winners of each semi play in finals
    s1 = section.round_robin_matches.where(match: 100).first
    s2 = section.round_robin_matches.where(match: 101).first

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

    RoundRobinMatch.create(
      section_id: section.id,
      court: section.start_court,
      match: 200,
      entry_a_id: w1,
      entry_b_id: w2
    )
  end
  
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