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
            courts_remaining = sections.active.sum(&:number_of_courts)
            entries_remaining = sections.sum(&:number_of_teams)
            from_sections = []
            to_sections = []

            sections.each do |section|
                case 
                when !section.active
                    should_have = 0
                when courts_remaining == section.number_of_courts
                    should_have = entries_remaining
                else
                    should_have = (((entries_remaining.to_f / courts_remaining * section.number_of_courts) + 1)  / 2).to_i * 2
                end

                section.number_in_draw = should_have
                section.save(validate: false)

                if section.number_of_teams != should_have
                    logger.info "->#{section.name} - has #{section.number_of_teams}, should have #{should_have}"

                    if section.number_of_teams > should_have
                        from_sections << section
                    else
                        to_sections << section
                    end
                end

                entries_remaining -= should_have
                courts_remaining -= section.number_of_courts unless !section.active
            end

            from_sections.each do |section|
                logger.info "--> Moving entries from #{section.name}"
                entries = section.entries_allowed_to_be_moved

                while section.number_of_teams > section.number_in_draw
                    new_section = to_sections.first
                    moving_entry = entries.shift

                    if moving_entry.venue_name != new_section.venue_name
                        logger.info "*--> Entry in #{moving_entry.section_name} (#{moving_entry.name}) moving from #{moving_entry.venue_name} to #{new_section.venue_name}"
                    end

                    logger.info "---> Moving #{moving_entry.name} to #{new_section.name}"
                    moving_entry.section_id = new_section.id
                    moving_entry.save(validate: false)

                    if new_section.number_of_teams == new_section.number_in_draw
                        to_sections.shift
                    end
                end
            end
        end
    end
end