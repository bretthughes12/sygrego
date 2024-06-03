class InfoController < ApplicationController
    # GET /info/knockout_reference
    def knockout_reference
        redirect_to rails_blob_path(@settings.knockout_reference)
    end

    # GET /info/ladder_reference
    def ladder_reference
        redirect_to rails_blob_path(@settings.ladder_reference)
    end

    # GET /info/results_reference
    def results_reference
        redirect_to rails_blob_path(@settings.results_reference)
    end

    # GET /info/sports_maps
    def sports_maps
        redirect_to rails_blob_path(@settings.sports_maps)
    end
end
