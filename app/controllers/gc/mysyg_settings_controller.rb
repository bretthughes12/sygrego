class Gc::MysygSettingsController < GcController
    load_and_authorize_resource
  
    # GET /gc/mysyg_settings/1/edit
    def edit
      render layout: @current_role.name
    end
  
    # GET /gc/mysyg_settings/1/edit_team_sports
    def edit_team_sports
      @team_grades = Grade.team.order('grades.name').load
      render layout: @current_role.name
    end
  
    # GET /gc/mysyg_settings/1/edit_indiv_sports
    def edit_indiv_sports
      @indiv_grades = Grade.individual.order('grades.name').load
      render layout: @current_role.name
    end
  
    # GET /gc/mysyg_settings/1/new_policy
    def new_policy
      render layout: @current_role.name
    end
  
    # PATCH /gc/mysyg_settings/1
    def update
      respond_to do |format|
        if @mysyg_setting.update(mysyg_setting_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "edit", layout: @current_role.name }
        end
      end
    end

    # PATCH /gc/mysyg_settings/1/update_team_sports
    def update_team_sports
      respond_to do |format|
        if @mysyg_setting.update(mysyg_setting_team_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "edit_team_sports", layout: @current_role.name }
        end
      end
    end

    # PATCH /gc/mysyg_settings/1/update_indiv_sports
    def update_indiv_sports
      respond_to do |format|
        if @mysyg_setting.update(mysyg_setting_indiv_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "edit_indiv_sports", layout: @current_role.name }
        end
      end
    end
  
    # PATCH /gc/mysyg_settings/1/update_policy
    def update_policy
      respond_to do |format|
        if @mysyg_setting.update(mysyg_setting_policy_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to home_gc_info_path }
        else
          format.html { render action: "new_policy", layout: @current_role.name }
        end
      end
    end
  
    # PATCH /gc/mysyg_settings/1/purge_policy
    def purge_policy
      @mysyg_setting.policy.purge

      respond_to do |format|
          format.html { render action: "new_policy", layout: @current_role.name }
      end
    end

    private
  
    def mysyg_setting_params
      params.require(:mysyg_setting).permit(:mysyg_open,
        :instructions,
        :extra_fee_total,
        :extra_fee_per_day,
        :require_emerg_contact,
        :require_medical,
        :show_sports_on_signup,
        :show_sports_in_mysyg,
        :show_volunteers_in_mysyg,
        :show_finance_in_mysyg,
        :show_group_extras_in_mysyg,
        :approve_option
      )
    end

    def mysyg_setting_team_params
      params.require(:mysyg_setting).permit(
        :team_sport_view_strategy
      )
    end

    def mysyg_setting_indiv_params
      params.require(:mysyg_setting).permit(
        :indiv_sport_view_strategy
      )
    end
  
    def mysyg_setting_policy_params
      params.require(:mysyg_setting).permit( 
        :policy,
        :policy_text
      )
    end
end
