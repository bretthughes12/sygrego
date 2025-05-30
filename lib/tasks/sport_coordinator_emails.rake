# frozen_string_literal: true

namespace :syg do
    desc 'Send emails to all applicable volunteers'
    task send_volunteer_emails: ['db:migrate'] do |_t|
      Volunteer.each do |volunteer|
        if volunteer.to_receive_emails?
          if volunteer.participant.nil?
            puts "Email skipped for #{volunteer.description}"
          elsif volunteer.email_template_to_use == 'Sport Coordinator'
            VolunteerMailer.welcome(volunteer).deliver
            puts "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
          elsif volunteer.email_template_to_use == 'Default'
            VolunteerMailer.default_instructions(volunteer).deliver
            puts "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
          else
            puts "Email template not supported for #{volunteer.description}"
          end
        else
          puts "Email not defined for #{volunteer.description}"
        end
      end
    end
  
    desc 'Send test volunteer email'
    task send_test_volunteer_email: ['db:migrate'] do |_t|
      [1164].each do |id|
      # [1429, 1164, 1672].each do |id|
        volunteer = Volunteer.find(id)
        
        if volunteer.to_receive_emails?
          if volunteer.participant.nil?
            puts "Email skipped for #{volunteer.description}"
          elsif volunteer.email_template_to_use == 'Sport Coordinator'
            VolunteerMailer.welcome(volunteer, test_run: true).deliver
            puts "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
          elsif volunteer.email_template_to_use == 'Default'
            VolunteerMailer.default_instructions(volunteer, test_run: true).deliver
            puts "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
          else
            puts "Email template not supported for #{volunteer.description}"
          end
        else
          puts "Email not defined for #{volunteer.description}"
        end
      end
    end
  
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
  
    desc 'Send emails to specific sport coordinators'
    task send_sport_coordinator_emails_specific: ['db:migrate'] do |_t|
        [300, 304, 305, 308, 313, 314, 333, 334, 344, 348, 349,
         355, 358, 360, 361, 324, 368, 370, 372, 379, 380, 381,
         383, 382, 384, 385, 387, 388, 389, 391, 393, 672, 394,
         397, 402, 403, 405, 669, 409, 414, 671, 424, 427, 429,
         431, 433, 434, 435, 436, 438, 439, 440, 441, 443, 444,
         445, 446, 447, 448].each do |i|
            volunteer = Volunteer.where(id: i).first
            if volunteer.nil?
                puts "Email skipped for #{i} -- not found"
            elsif volunteer.participant.nil?
                puts "Email skipped for #{volunteer.description}"
            else
                VolunteerMailer.welcome(volunteer).deliver
                puts "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
            end
        end
    end
  
    desc 'Send test email to a single sport coordinator'
    task send_test_sport_coordinator_email: ['db:migrate'] do |_t|
       volunteer = Volunteer.find(1044)
#       volunteer = Volunteer.find(300)
  
      if volunteer.participant.nil?
        puts "Email skipped for #{volunteer.description}"
      else
        VolunteerMailer.welcome(volunteer).deliver
        puts "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
      end
    end
  end
  