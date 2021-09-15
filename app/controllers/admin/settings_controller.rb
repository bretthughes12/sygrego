class Admin::SettingsController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!

    # GET /settings/1
    def show
      @setting = Setting.find(params[:id])
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /settings/1/edit
    def edit
        @setting = Setting.find(params[:id])
    end
  
    # GET /settings/1/edit_functionality
    def edit_functionality
      @setting = Setting.find(params[:id])
  end

  # PUT /settings/1
    def update
      @setting = Setting.find(params[:id])

      respond_to do |format|
        if @setting.update(settings_params)
          flash[:notice] = 'Settings were successfully updated.'
          format.html { render action: "edit" }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
  private
  
    def settings_params
      params.require(:setting).permit(:generate_stats,
                                      :early_bird,
                                      :sports_loaded,
                                      :volunteers_loaded,
                                      :group_registrations_closed, 
                                      :restricted_sports_allocated, 
                                      :indiv_draws_complete,
                                      :team_draws_complete,
                                      :evening_sessions_final,
                                      :updates_restricted,
                                      :syg_is_happening,
                                      :syg_is_finished,
                                      :new_group_sports_allocation_factor,
                                      :sport_coord_sports_allocation_factor,
                                      :missed_out_sports_allocation_factor,
                                      :small_division_ceiling,
                                      :medium_division_ceiling,
                                      :full_fee,
                                      :day_visitor_adjustment,
                                      :coordinator_adjustment,
                                      :spectator_adjustment,
                                      :primary_age_adjustment,
                                      :daily_adjustment,
                                      :helper_adjustment,
                                      :early_bird_discount)
    end
  end
