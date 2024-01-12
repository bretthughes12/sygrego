class VolunteerMailer < ApplicationMailer
    default from: 'sportadmin@stateyouthgames.com',
            cc:   ['sports@stateyouthgames.com', 'sportadmin@stateyouthgames.com', 'registrations@stateyouthgames.com']
    
    def welcome(volunteer)
      @sport = volunteer.sport
      @sections = volunteer.sections
      
      mail(to:      volunteer.email_recipients, 
           subject: "#{APP_CONFIG[:email_subject]} SYG #{APP_CONFIG[:this_year]} - Welcome Sports Coordinators - #{volunteer.description}")
    end
end
  