class VolunteerMailer < ApplicationMailer
    default from: 'sportadmin@stateyouthgames.com',
            cc:   ['sports@stateyouthgames.com', 'sportadmin@stateyouthgames.com', 'registrations@stateyouthgames.com']
    
    def welcome(volunteer, test_run: false)
      recipients = test_run ? 'registrations@stateyouthgames.com' : volunteer.email_recipients

      @sport = volunteer.sport
      @sections = volunteer.sections
      @draw_types = @sections.collect(&:draw_type).flatten.uniq
      
      mail(to:      recipients, 
           subject: "#{APP_CONFIG[:email_subject]} SYG #{APP_CONFIG[:this_year]} - Welcome Sports Coordinators - #{volunteer.description}")
    end
    
    def default_instructions(volunteer, test_run: false)
      recipients = test_run ? 'registrations@stateyouthgames.com' : volunteer.email_recipients

      mail(to:      recipients,
           cc:      [volunteer.cc_email, 'registrations@stateyouthgames.com'],
           from:    volunteer.cc_email,
           subject: "#{APP_CONFIG[:email_subject]} SYG #{APP_CONFIG[:this_year]} - Volunteer Instructions - #{volunteer.description}")
    end
end
  