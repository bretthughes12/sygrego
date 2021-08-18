# frozen_string_literal: true

namespace :syg do
    require 'csv'
    require 'pp'

    desc 'Load / update sports table into the database'
    task load_sports: ['db/data/sport.csv', 'db:migrate'] do |t|
        puts 'Loading sports...'
        CSV.foreach(t.prerequisites.first) do |fields|
            if fields[1] == 'true' || fields[1] == 'TRUE' # sport is active this year
                sport = Sport.find_by_name(fields[0].to_s)
                if sport
                    sport.active = fields[1]
                    sport.classification = fields[2].to_s
                    sport.max_indiv_entries_group = fields[3].to_i
                    sport.max_team_entries_group = fields[4].to_i
                    sport.max_entries_indiv = fields[5].to_i
                    sport.bonus_for_officials = fields[6]
                    sport.court_name = fields[7]
                    sport.draw_type = fields[8]
                    if sport.save
#                       log(sport, 'UPDATE')
                        puts "Updated sport #{fields[0]}"
                    else
                        puts "Sport update failed: #{fields[0]}"
                        pp sport.errors                        
                    end
                else
                    sport = Sport.create(
                              name:                      fields[0],
                              active:                    fields[1],
                              classification:            fields[2],
                              draw_type:                 fields[8],
                              max_indiv_entries_group:   fields[3].to_i,
                              max_team_entries_group:    fields[4].to_i,
                              max_entries_indiv:         fields[5].to_i,
                              bonus_for_officials:       fields[6],
                              court_name:                fields[7])
                    if sport.errors.empty?
#                       log(sport, 'CREATE')
                        puts "Created sport #{fields[1]}"
                    else
                        puts "Sport create failed: #{fields[1]}"
                        pp sport.errors                        
                    end
                end
            end
        end
    end
end
    
  