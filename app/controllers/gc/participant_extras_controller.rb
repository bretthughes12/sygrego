class Gc::ParticipantExtrasController < GcController
    load_and_authorize_resource

    def index
      @participant_extras = @group.participant_extras
      
      respond_to do |format|
        format.html # index.html.erb
        format.xlsx do 
          render xlsx: "index", filename: "wanted_extras.xlsx"
        end
      end
    end
end