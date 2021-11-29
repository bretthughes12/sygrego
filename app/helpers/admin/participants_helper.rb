module Admin::ParticipantsHelper
    def participant_display_class(participant)
        case
        when participant.coming && participant.spectator
            "table-warning"
        when participant.coming
            "table-primary"
        else
            "table-dark"
        end
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
    
    def name_with_group_name(participant)
        if participant.group.nil?
          participant.name
        else
          participant.name + ' (' + participant.group.short_name + ')'
        end
    end

    def name_with_captaincy_suffix(participant, captain)
        if participant == captain
            participant.name + ' (c)'
        else
            participant.name
        end
    end
end
