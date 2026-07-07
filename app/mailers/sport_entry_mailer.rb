class SportEntryMailer < ApplicationMailer
    default from: 'registrations@stateyouthgames.com',
            to:    ['sports@stateyouthgames.com', 'registrations@stateyouthgames.com'],
            cc:    'sportadmin@stateyouthgames.com'
  
    def restricted_sport_withdrawal(entry)
      @entry = entry
  
      if @settings.send_emails
        mail(subject: "#{APP_CONFIG[:email_subject]} Withdrawal from #{entry.section_name}")
      end
    end
  
    def restricted_sport_offer(entry)
      @entry = entry
      # entries_missed_out = @entry.grade.entries_waiting
      notifies = @entry.grade.entries_waiting.collect do |e|
        e.group.email_recipients
      end.flatten.uniq
  
      if @settings.send_emails
        mail(from:    @settings.sports_email,
             bcc:     notifies,
           subject: "#{APP_CONFIG[:email_subject]} Restricted Sports Offer - #{entry.section_name}") do |format|
          format.html { render layout: 'mailer' }
          format.text
        end
      end
    end
  
    def draw_entry_withdrawal(entry)
      @entry = entry
  
      if @settings.send_emails
        mail(subject: "#{APP_CONFIG[:email_subject]} Draw affected: Withdrawal from #{entry.section_name}")
      end
    end
  
    def draw_entry_addition(entry)
      @entry = entry
  
      if @settings.send_emails
        mail(subject: "#{APP_CONFIG[:email_subject]} Draw affected: New entry in #{entry.section_name}")
      end
    end
end
  