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

    # GET /admin/settings/1/edit_event
    def edit_event
      @setting = Setting.find(params[:id])
    end
  
    # GET /admin/settings/1/edit_functionality
    def edit_functionality
      @setting = Setting.find(params[:id])
    end

    # GET /admin/settings/1/edit_email
    def edit_email
      @setting = Setting.find(params[:id])
    end

    # GET /admin/settings/1/edit_social
    def edit_social
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

    # GET /admin/settings/1/edit_website
    def edit_website
      @setting = Setting.find(params[:id])
    end

    # GET /admin/settings/1/edit_references
    def edit_references
      @setting = Setting.find(params[:id])
    end

  # PATCH /admin/settings/1
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
  
  # PATCH /admin/settings/1/update_event
  def update_event
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update(settings_params)
        flash[:notice] = 'Event settings were successfully updated.'
        format.html { render action: "edit_event" }
      else
        format.html { render action: "edit_event" }
      end
    end
  end
  
  # PATCH /admin/settings/1/update_functionality
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
  
  # PATCH /admin/settings/1/update_email
  def update_email
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update(settings_params)
        flash[:notice] = 'Email settings were successfully updated.'
        format.html { render action: "edit_email" }
      else
        format.html { render action: "edit_email" }
      end
    end
  end
  
  # PATCH /admin/settings/1/update_social
  def update_social
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update(settings_params)
        flash[:notice] = 'Social links were successfully updated.'
        format.html { render action: "edit_social" }
      else
        format.html { render action: "edit_social" }
      end
    end
  end
  
  # PATCH /admin/settings/1/update_fees
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
  
  # PATCH /admin/settings/1/update_divisions
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
  
  # PATCH /admin/settings/1/update_sports_factors
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
  
  # PATCH /admin/settings/1/update_website
  def update_website
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update(settings_params)
        flash[:notice] = 'Website admin settings were successfully updated.'
        format.html { render action: "edit_website" }
      else
        format.html { render action: "edit_website" }
      end
    end
  end
  
  # PATCH /admin/settings/1/update_references
  def update_references
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update(settings_params)
        flash[:notice] = 'Reference files were successfully updated.'
        format.html { render action: "edit_references" }
      else
        format.html { render action: "edit_references" }
      end
    end
  end
  
  # PATCH /admin/settings/1/purge_knockout_reference
  def purge_knockout_reference
    @setting = Setting.find(params[:id])

    @setting.knockout_reference.purge

    respond_to do |format|
      format.html { render action: "edit_references" }
    end
  end
  
  # PATCH /admin/settings/1/purge_ladder_reference
  def purge_ladder_reference
    @setting = Setting.find(params[:id])

    @setting.ladder_reference.purge

    respond_to do |format|
      format.html { render action: "edit_references" }
    end
  end
  
  # PATCH /admin/settings/1/purge_results_reference
  def purge_results_reference
    @setting = Setting.find(params[:id])

    @setting.results_reference.purge

    respond_to do |format|
      format.html { render action: "edit_references" }
    end
  end
  
  # PATCH /admin/settings/1/purge_sports_reference
  def purge_sports_reference
    @setting = Setting.find(params[:id])

    @setting.sports_reference.purge

    respond_to do |format|
      format.html { render action: "edit_references" }
    end
  end
  
  # PATCH /admin/settings/1/purge_sports_maps
  def purge_sports_maps
    @setting = Setting.find(params[:id])

    @setting.sports_maps.purge

    respond_to do |format|
      format.html { render action: "edit_references" }
    end
  end

  private
  
    def settings_params
      params.require(:setting).permit(:generate_stats,
                                      :early_bird,
                                      :sports_loaded,
                                      :volunteers_loaded,
                                      :group_registrations_closed, 
                                      :participant_registrations_closed, 
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
                                      :early_bird_discount,
                                      :info_email,
                                      :admin_email,
                                      :rego_email,
                                      :sports_email,
                                      :sports_admin_email,
                                      :ticket_email,
                                      :lost_property_email,
                                      :finance_email,
                                      :comms_email,
                                      :this_year,
                                      :first_day_of_syg,
                                      :early_bird_cutoff,
                                      :deposit_due_date,
                                      :social_twitter_url,
                                      :social_facebook_url,
                                      :social_facebook_gc_url,
                                      :social_instagram_url,
                                      :social_youtube_url,
                                      :social_spotify_url,
                                      :public_website,
                                      :rego_website,
                                      :website_host,
                                      :knockout_reference,
                                      :ladder_reference,
                                      :results_reference,
                                      :sports_reference,
                                      :sports_maps
                                    )

    end
  end
