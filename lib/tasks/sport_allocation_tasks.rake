namespace :syg do
    desc 'Initialise sections  on sport entries in grades with multiple sections'
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
end