class SectionsController < ApplicationController
    # GET /section/1/draw_file
    def draw_file
        @section = Section.where(id: params[:id]).first

        if @section && @section.draw_file.attached?
            redirect_to rails_blob_path(@section.draw_file)
        else
            redirect_to home_url(current_user)
        end
    end
end
