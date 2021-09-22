class ApplicationController < ActionController::Base

    before_action :get_settings

    def get_settings
        @settings ||= Setting.first
    end
    
    def render_csv(filename = nil, action = nil)
        filename ||= params[:action]
        filename += '.csv'
        action ||= params[:action]
      
        headers["Content-Type"] ||= 'text/csv'
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
      
        render layout: false, action: action
    end
    
end
