class TasksMailer < ApplicationMailer
    def allocations_done
        mail(to:      [@settings.rego_email, @settings.sports_email, @settings.sports_admin_email],
             subject: "#{APP_CONFIG[:email_subject]} Restricted Sports Allocation completed")
    end
    
    def grade_allocations_done
        mail(to:      @settings.rego_email,
            subject: "#{APP_CONFIG[:email_subject]} Grade Allocation to Sections completed") 
    end
end