namespace :syg do
    desc 'Initialise sections on sport entries in grades with multiple sections'
    task initialise_sport_entry_sections: ['db:migrate'] do |t|
        puts 'Initialising sections on sport entries...'

        entry_count = 0

        Grade.restricted.each do |grade|
            if grade.sections.count > 1
                grade.sport_entries.requested.each do |entry|
                    entry.section_id = nil
                    entry.save(validate: false)
                    entry_count += 1
                end
            end
        end

        puts "Entries - #{entry_count}"
    end

    desc 'Set start court for sections where there are multiple in the same venue and session'
    task set_start_court: ['db:migrate'] do |t|
        puts 'Setting start court for sections...'
        section_count = 0
        prev_session_id = 0
        prev_venue_id = 0
        prev_sport = Sport.first
        next_court = 1
        Section.order(:session_id, :venue_id, :name).all.each do |section|
            if section.sport.classification == 'Team'
                if section.sport != prev_sport || section.session_id != prev_session_id || section.venue_id != prev_venue_id
                    # Reset the next_court counter if we are in a new session or venue
                    next_court = 1
                    prev_session_id = section.session_id
                    prev_venue_id = section.venue_id
                    prev_sport = section.sport
                end
                if section.start_court != next_court
                    # Increment the next_court counter if we are in the same session and venue
                    puts "Session: #{section.session.name}; Venue: #{section.venue.name}; Section #{section.name} - Start court changed from #{section.start_court} to #{next_court}"
                    section.start_court = next_court
                    section.save(validate: false)
                    section_count += 1
                end
                next_court += section.number_of_courts
            end
        end
        puts "Sections updated - #{section_count}"
    end
end