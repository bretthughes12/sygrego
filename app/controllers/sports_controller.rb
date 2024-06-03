class SportsController < ApplicationController
    # GET /sport/1/rules_file
    def rules_file
        @sport = Sport.where(id: params[:id]).first

        if @sport && @sport.rules_file.attached?
            redirect_to rails_blob_path(@sport.rules_file)
        else
            redirect_to home_url(current_user)
        end
    end
end
