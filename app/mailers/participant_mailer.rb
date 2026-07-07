class ParticipantMailer < ApplicationMailer
    def transfer(participant, token)
        @participant = participant
        @token = token
    
        if @settings.send_emails
            mail(to:      @participant.transfer_email, 
                    subject: "#{APP_CONFIG[:email_subject]} SYG Registration")
        end
    end
end
  