module Admin::ParticipantsHelper
    def participant_display_class(participant)
    
    end

    def can_display_onsite_flag
        @group.onsite 
    end
      
    def can_display_helper_flag
        true
#        group = @participant.group || @group
#        @participant.helper || (group.participants.coming.accepted.helpers.size < group.helpers_allowed)
    end
      
    def can_display_group_coord_flag
        true
#        group = @participant.group || @group
#        @current_user.role?(:admin) || @participant.group_coord || (group.participants.coming.accepted.group_coords.size < group.coordinators_allowed)
    end
    
end
