class UserMailer < ApplicationMailer
    def welcome_church_rep(user)
        @user = user
        if @settings.send_emails
            mail(to:      user.email, 
                 subject: "#{APP_CONFIG[:email_subject]} Welcome to the SYG Registrations website")
        end
    end
    
    def gc_nomination(user, group, church_rep, token)
        @user = user
        @group = group
        @church_rep = church_rep
        @token = token
    
        if @settings.send_emails
            mail(to:      user.email, 
                 subject: "#{APP_CONFIG[:email_subject]} SYG Group Coordinator Nomination")
        end
    end

    def gc_approval(user, group)
        @user = user
        @group = group
        
        if @settings.send_emails
            mail(to:      user.email, 
                 subject: "#{APP_CONFIG[:email_subject]} Welcome Group Coordinator")
        end
    end
    
    def welcome_participant(user, participant)
        @user = user
        @participant = participant
        @group = @participant.group
    
        if @settings.send_emails
            mail(to:      user.email, 
                 subject: "#{APP_CONFIG[:email_subject]} Welcome to the SYG Registrations website")
        end
    end
    
    def reject_participant(participant, group)
        @participant = participant
        @user = participant.users.first
        @group = group
        
        if @settings.send_emails
            mail(to:      @settings.rego_email, 
                 subject: "#{APP_CONFIG[:email_subject]} Participant rejected by #{group.short_name}")
        end
    end
    
    def accept_participant(participant, group, token)
        @participant = participant
        @user = participant.users.first
        @group = group
        @token = token
        
        if @settings.send_emails
            mail(to:      @user.email, 
                 subject: "#{APP_CONFIG[:email_subject]} Participant accepted by #{group.short_name}")
        end
    end
    
    def new_participant(user, participant)
        @user = user
        @participant = participant
        @group = @participant.group
        notifies = @participant.group.email_recipients
    
        if @settings.send_emails
            mail(to:      notifies,
                 subject: "#{APP_CONFIG[:email_subject]} New participant details (#{@group.short_name}): #{participant.first_name} #{participant.surname}") 
        end
    end
end
  