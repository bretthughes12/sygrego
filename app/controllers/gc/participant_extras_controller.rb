class Gc::ParticipantExtrasController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group

    layout "gc"

    def index
      @participant_extras = @group.participant_extras
      
      respond_to do |format|
        format.html # index.html.erb
      end
    end
end