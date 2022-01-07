class Gc::MysygSettingsController < ApplicationController
    load_and_authorize_resource except: [:show]
    before_action :authenticate_user!
    before_action :find_group
    
    layout "gc"
  
    # GET /gc/mysyg_settings/1/edit
    def edit
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

    private
  
    def mysyg_setting_params
      params.require(:mysyg_setting).permit(:mysyg_open,
        :participant_instructions,
        :extra_fee_total,
        :extra_fee_per_day,
        :show_sports_in_mysyg,
        :show_volunteers_in_mysyg,
        :show_finance_in_mysyg,
        :show_group_extras_in_mysyg,
        :approve_option,
        :team_sport_view_strategy,
        :indiv_sport_view_strategy,
    )
end
end
