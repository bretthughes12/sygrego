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
        grade.possible_sessions.each do |session|
            sections = session.sections.where(grade_id: grade.id).load
            total_courts = sections.active.sum(&:number_of_courts)
            total_entries = sections.sum(&:number_of_teams)
            teams_per_court = (total_entries / total_courts).ceil

            sections.active.each do |section|
                puts "#{section.name} - has #{section.number_of_teams}, should have #{section.number_of_courts * teams_per_court}"
            end
        end
    end

    def set_number_in_draw(grade)
        
    end
end