class UserMailer < ActionMailer::Base
    default from: 'registrations@stateyouthgames.com'
    layout 'mailer'
    before_action :get_settings
  
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

    private

    def get_settings
        @settings ||= Setting.first
    end
  end
  