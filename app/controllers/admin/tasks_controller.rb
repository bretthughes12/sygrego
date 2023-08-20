class Admin::TasksController < AdminController
  before_action :authenticate_user!

  # GET /admin/tasks/sports_draws
  def sports_draws
  end

  # POST /admin/tasks/allocate_restricted
  def allocate_restricted
    if !@settings.restricted_sports_allocated
      AllocateRestrictedJob.perform_later
      set_restricted_sports_allocated_setting
      flash[:notice] = 'Restricted sports allocation is under way. Look for an email when finished'
    else
      flash[:notice] = 'ERROR - Restricted sports are already allocated'
    end
    
    redirect_to summary_admin_ballot_results_path 
  end
    
  # POST /admin/tasks/finalise_team_sports
  def finalise_team_sports
    if !@settings.team_draws_complete
      FinaliseGradesJob.perform_later(:team)
      set_team_draws_complete_setting
      flash[:notice] = 'Finalisation of team grades is under way. Look for an email when finished'
    else
      flash[:notice] = 'ERROR - Team grades are already finalised'
    end
    
    redirect_to sports_draws_admin_tasks_path
  end
    
  # POST /admin/tasks/finalise_individual_sports
  def finalise_individual_sports
    if !@settings.indiv_draws_complete
      FinaliseGradesJob.perform_later(:individual)
      set_indiv_draws_complete_setting
      flash[:notice] = 'Finalisation of individual grades is under way. Look for an email when finished'
    else
      flash[:notice] = 'ERROR - Individual grades are already finalised'
    end
    
    redirect_to sports_draws_admin_tasks_path
  end
  
  private
  
  def set_restricted_sports_allocated_setting
    @settings.restricted_sports_allocated = true
    @settings.save(validate: false)
  end
  
  def set_team_draws_complete_setting
    @settings.team_draws_complete = true
    @settings.save(validate: false)
  end
  
  def set_indiv_draws_complete_setting
    @settings.indiv_draws_complete = true
    @settings.save(validate: false)
  end
end
