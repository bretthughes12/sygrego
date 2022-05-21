class TasksMailer < ApplicationMailer
    def allocations_done
        mail(to:      [@settings.rego_email, @settings.sports_email, @settings.sports_admin_email],
             subject: "#{APP_CONFIG[:email_subject]} Restricted Sports Allocation completed")
    end
    
    def grades_finalised
        mail(to:      @settings.rego_email,
            subject: "#{APP_CONFIG[:email_subject]} Grades Finalised and ready for Sports Draws") 
    end
end