class FinaliseGradesJob < ApplicationJob
    queue_as :default
  
    def perform(type)
        if type == :team
            grades = Grade.team.active.closed.load
        else
            grades = Grade.individual.active.closed.load
        end

        grades.each do |grade|
            balance_sections_in_grade(grade)
            set_number_in_draw(grade)
      
            grade.status = "Allocated"
            grade.entry_limit = grade.sport_entries.entered.count
            grade.save(validate: false)
        end

        TasksMailer.grades_finalised.deliver_now
    end

    private

    def balance_sections_in_grade(grade)
        
    end

    def set_number_in_draw(grade)
        
    end
end