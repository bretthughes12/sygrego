class ApplicationController < ActionController::Base

    def render_csv(filename = nil, action = nil)
        filename ||= params[:action]
        filename += '.csv'
        action ||= params[:action]
      
        headers["Content-Type"] ||= 'text/csv'
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
      
        render layout: false, action: action
    end
    
end
