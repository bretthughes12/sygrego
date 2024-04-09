class Admin::MysygSettingsController < AdminController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
    
    # GET /admin/mysyg_settings
    def index
      @mysyg_settings = MysygSetting.includes(:group).where("groups.coming = true").all.order("groups.abbr").load
  
      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "mysyg_setting", "mysyg_setting" }
        format.xlsx { render xlsx: "index", filename: "mysyg_settings.xlsx" }
      end
    end

    # GET /admin/mysyg_settings/search
    def search
      @groups = Group.search(params[:search]).order("abbr")
      @mysyg_settings = @groups.collect(&:mysyg_setting)
  
      respond_to do |format|
        format.html { render action: 'index' }
      end
    end

    # GET /admin/mysyg_settings/1
    def show
    end
  
    # GET /admin/mysyg_settings/1/edit
    def edit
    end
  
    # PATCH /admin/mysyg_settings/1
    def update
      respond_to do |format|
        if @mysyg_setting.update(mysyg_setting_params)
          flash[:notice] = 'Settings were successfully updated.'
          format.html { redirect_to admin_mysyg_settings_url }
        else
          format.html { render action: "edit" }
        end
      end
    end

    # GET /admin/mysyg_settings/new_import
    def new_import
      @mysyg_setting = MysygSetting.new
    end
  
    # POST /admin/mysyg_settings/import
    def import
      if params[:mysyg_setting] && params[:mysyg_setting][:file].path =~ %r{\.xlsx$}i
        result = MysygSetting.import_excel(params[:mysyg_setting][:file], current_user)

        flash[:notice] = "MySYG Settings upload complete: #{result[:creates]} details created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_mysyg_settings_url }
        end
      else
        flash[:notice] = "Upload file must be in '.xlsx' format"
        @mysyg_setting = MysygSetting.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end

    private
  
    def mysyg_setting_params
      params.require(:mysyg_setting).permit(:mysyg_enabled, 
                                    :mysyg_open,
                                    :instructions,
                                    :extra_fee_total,
                                    :extra_fee_per_day,
                                    :show_sports_on_signup,
                                    :show_sports_in_mysyg,
                                    :show_volunteers_in_mysyg,
                                    :show_finance_in_mysyg,
                                    :show_group_extras_in_mysyg,
                                    :require_emerg_contact,
                                    :require_medical,
                                    :approve_option,
                                    :team_sport_view_strategy,
                                    :indiv_sport_view_strategy,
                                    :mysyg_code
                                )
    end
end
