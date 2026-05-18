class UserMailer < ApplicationMailer
    def welcome_church_rep(user)
        @user = user
        mail(to:      user.email, 
             subject: "#{APP_CONFIG[:email_subject]} Welcome to the SYG Registrations website")
    end
    
    def gc_nomination(user, group, church_rep, token)
        @user = user
        @group = group
        @church_rep = church_rep
        @token = token
    
        mail(to:      user.email, 
             subject: "#{APP_CONFIG[:email_subject]} SYG Group Coordinator Nomination")
    end

    def gc_approval(user, group)
        @user = user
        @group = group
        
        mail(to:      user.email, 
             subject: "#{APP_CONFIG[:email_subject]} Welcome Group Coordinator")
    end
    
    def welcome_participant(user, participant)
        @user = user
        @participant = participant
        @group = @participant.group
    
        mail(to:      user.email, 
             subject: "#{APP_CONFIG[:email_subject]} Welcome to the SYG Registrations website")
    end
    
    def reject_participant(participant, group)
        @participant = participant
        @user = participant.users.first
        @group = group
        
        mail(to:      @settings.rego_email, 
             subject: "#{APP_CONFIG[:email_subject]} Participant rejected by #{group.short_name}")
    end
    
    def accept_participant(participant, group, token)
        @participant = participant
        @user = participant.users.first
        @group = group
        @token = token
        
        mail(to:      @user.email, 
             subject: "#{APP_CONFIG[:email_subject]} Participant accepted by #{group.short_name}")
    end
    
    def new_participant(user, participant)
        @user = user
        @participant = participant
        @group = @participant.group
        notifies = @participant.group.email_recipients
    
        mail(to:      notifies,
             subject: "#{APP_CONFIG[:email_subject]} New participant details (#{@group.short_name}): #{participant.first_name} #{participant.surname}") 
    end
end
  