class UpdateGradeLimitsJob < ApplicationJob
    queue_as :default
  
    def perform(type)
        if type == :team
            grades = Grade.team.active.allocated.load
        else
            grades = Grade.individual.active.allocated.load
        end

        grades.each do |grade|
            if grade.sport_entries.entered.count != grade.entry_limit
                grade.entry_limit = grade.sport_entries.entered.count
                grade.save(validate: false)
                puts "Updated grade limits for #{grade.name} to #{grade.entry_limit}"
            end
        end
    end
end