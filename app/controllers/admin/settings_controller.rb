class Admin::SettingsController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!

    # GET /admin/settings/1
    def show
      @setting = Setting.find(params[:id])
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/settings/1/edit
    def edit
        @setting = Setting.find(params[:id])
    end
  
    # GET /admin/settings/1/edit_functionality
    def edit_functionality
      @setting = Setting.find(params[:id])
    end

    # GET /admin/settings/1/edit_fees
    def edit_fees
      @setting = Setting.find(params[:id])
    end

    # GET /admin/settings/1/edit_divisions
    def edit_divisions
      @setting = Setting.find(params[:id])
    end

    # GET /admin/settings/1/edit_sports_factors
    def edit_sports_factors
      @setting = Setting.find(params[:id])
    end

  # PUT /admin/settings/1
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
  
  # PUT /admin/settings/1/update_functionality
  def update_functionality
      @setting = Setting.find(params[:id])

      respond_to do |format|
        if @setting.update(settings_params)
          flash[:notice] = 'Functionality settings were successfully updated.'
          format.html { render action: "edit_functionality" }
        else
          format.html { render action: "edit_functionality" }
        end
      end
    end
  
  # PUT /admin/settings/1/update_fees
  def update_fees
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update(settings_params)
        flash[:notice] = 'Fee settings were successfully updated.'
        format.html { render action: "edit_fees" }
      else
        format.html { render action: "edit_fees" }
      end
    end
  end
  
  # PUT /admin/settings/1/update_divisions
  def update_divisions
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update(settings_params)
        flash[:notice] = 'Division settings were successfully updated.'
        format.html { render action: "edit_divisions" }
      else
        format.html { render action: "edit_divisions" }
      end
    end
  end
  
  # PUT /admin/settings/1/update_sports_factors
  def update_sports_factors
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update(settings_params)
        flash[:notice] = 'Sports allocation factors were successfully updated.'
        format.html { render action: "edit_sports_factors" }
      else
        format.html { render action: "edit_sports_factors" }
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
