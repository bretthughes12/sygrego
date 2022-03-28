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
        @group.event_detail.onsite 
    end
      
    def can_display_helper_flag
        group = @participant.group || @group
        @participant.helper || group && (group.participants.coming.accepted.helpers.size < group.helpers_allowed)
    end
      
    def can_display_group_coord_flag
        group = @participant.group || @group
        @current_user.role?(:admin) || @participant.group_coord || group && (group.participants.coming.accepted.group_coords.size < group.coordinators_allowed)
    end

    def can_display_driver_fields
        @participant && (@participant.driver || @participant.age && @participant.age >= 18)
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

    def participant_type_class(participant)
        if participant.rego_type == "Full Time"
            "badge bg-success"
        else
            "badge bg-primary"
        end
    end

    def participant_status_class(participant)
        if participant.status == "Accepted"
            "badge bg-success"
        else
            "badge bg-danger"
        end
    end
end
