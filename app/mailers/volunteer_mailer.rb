class VolunteerMailer < ActionMailer::Base
    default from: 'sportadmin@stateyouthgames.com',
            cc:   ['sports@stateyouthgames.com', 'sportadmin@stateyouthgames.com', 'registrations@stateyouthgames.com']
    layout 'mailer'
    before_action :get_settings
    
    def welcome(volunteer)
      @sport = volunteer.sport
      @section = volunteer.section
      
      mail(to:      volunteer.email_recipients, 
           subject: "#{APP_CONFIG[:email_subject]} SYG #{APP_CONFIG[:this_year]} - Welcome Sports Coordinators")
    end

    private

    def get_settings
        @settings ||= Setting.first
    end
end
  