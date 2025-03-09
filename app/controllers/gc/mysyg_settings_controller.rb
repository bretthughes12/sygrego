class Gc::MysygSettingsController < GcController
    load_and_authorize_resource
  
    # GET /gc/mysyg_settings/1/edit
    def edit
      render layout: @current_role.name
    end
  
    # GET /gc/mysyg_settings/1/edit_team_sports
    def edit_team_sports
      @team_sports = Sport.team.order('name').load
      render layout: @current_role.name
    end
  
    # GET /gc/mysyg_settings/1/edit_indiv_sports
    def edit_indiv_sports
      @indiv_sports = Sport.individual.order('name').load
      render layout: @current_role.name
    end
  
    # GET /gc/mysyg_settings/1/new_policy
    def new_policy
      render layout: @current_role.name
    end
  
    # GET /gc/mysyg_settings/1/preview_signup
    def preview_signup
      @group = @mysyg_setting.group

      @participant_signup = ParticipantSignup.new
      @participant_signup.age = 30
      @participant_signup.coming_friday = true
      @participant_signup.coming_saturday = true
      @participant_signup.coming_sunday = true
      @participant_signup.coming_monday = true
      @participant_signup.onsite = @group.event_detail.onsite
      @participant_signup.group_id = @group.id
      
      @participant_signup.sport_preferences = SportPreference.prepare_for_group(@group)

      @start_questions = @group.questions.beginning
      @personal_questions = @group.questions.personal
      @medical_questions = @group.questions.medical
      @camping_questions = @group.questions.camping
      @sports_questions = @group.questions.sports
      @driving_questions = @group.questions.driving
      @disclaimer_questions = @group.questions.disclaimer

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
          format.html do
            @team_sports = Sport.team.order('name').load
            render action: "edit_team_sports", layout: @current_role.name
          end
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
          format.html do
            @indiv_sports = Sport.individual.order('name').load
            render action: "edit_indiv_sports", layout: @current_role.name
          end
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
        :email_text,
        :extra_fee_total,
        :extra_fee_per_day,
        :allow_part_time,
        :allow_offsite,
        :collect_age_by,
        :require_emerg_contact,
        :address_option,
        :allergy_option,
        :dietary_option,
        :medical_option,
        :medicare_option,
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
