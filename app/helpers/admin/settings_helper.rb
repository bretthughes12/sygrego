module Admin::SettingsHelper
    def registrations_open
        !@settings.participant_registrations_closed        
    end

    def gc_can_add_participants
        @settings.allow_gc_to_add_participants        
    end
end
