module Admin::SettingsHelper
    def registrations_open
        !@settings.participant_registrations_closed        
    end
end
