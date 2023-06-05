# frozen_string_literal: true

namespace :syg do
    desc 'Send emails to all sport coordinators'
    task send_sport_coordinator_emails: ['db:migrate'] do |_t|
      Volunteer.sport_coords.each do |volunteer|
        if volunteer.participant.nil?
          puts "Email skipped for #{volunteer.description}"
        else
          VolunteerMailer.welcome(volunteer).deliver
          puts "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
        end
      end
    end
  
    desc 'Send emails to sport coordinators where the email is blank'
    task send_sport_coordinator_emails_for_blank_email_addresses: ['db:migrate'] do |_t|
      Volunteer.sport_coords.each do |volunteer|
        if volunteer.participant && volunteer.email.blank?
          VolunteerMailer.welcome(volunteer).deliver
          puts "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
        else
          puts "Email skipped for #{volunteer.description}"
        end
      end
    end
  
    desc 'Send test email to a single sport coordinator'
    task send_test_sport_coordinator_email: ['db:migrate'] do |_t|
       volunteer = Volunteer.find(381)
#       volunteer = Volunteer.find(300)
  
      if volunteer.participant.nil?
        puts "Email skipped for #{volunteer.description}"
      else
        VolunteerMailer.welcome(volunteer).deliver
        puts "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
      end
    end
  end
  