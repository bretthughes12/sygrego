# frozen_string_literal: true

namespace :syg do
    require 'csv'
    require 'pp'

    desc 'Load / update sport sessions table into the database'
    task load_sessions: ['db/data/sport_session.csv', 'db:migrate'] do |t|
      puts 'Loading sport sessions...'

      user = User.first

      CSV.foreach(t.prerequisites.first) do |fields|
        if fields[0] != 'RowID'
          session = Session.find_by_database_rowid(fields[0].to_i)
          if session
            session.database_rowid = fields[0]
            session.name = fields[1]
            session.updated_by = user.id
            
            if session.save
              puts "Updated session #{fields[1]}"
            else
              puts "Session update failed: #{fields[1]}"
              pp session.errors                        
            end
          else
            session = Session.create(database_rowid: fields[0],
                                     name:           fields[1],
                                     updated_by:     user.id)

            if session.errors.empty?
              puts "Created session #{fields[1]}"
            else
              puts "Session create failed: #{fields[1]}"
              pp session.errors                        
            end
          end
        end
      end
    end
  
    desc 'Load / update sport venues table into the database'
    task load_venues: ['db/data/sport_venue.csv', 'db:migrate'] do |t|
      puts 'Loading sport venues...'

      user = User.first

      CSV.foreach(t.prerequisites.first) do |fields|
        if fields[0] != 'RowID' && !fields[0].blank?
          venue = Venue.find_by_database_code(fields[0].to_s)
          if venue
            venue.active               = fields[1]
            venue.name                 = fields[2]
            venue.address              = fields[3]
  
            if venue.save
              puts "Updated venue #{fields[2]}"
            else
              puts "Venue update failed: #{fields[2]}"
              pp venue.errors
            end                        
          else
            venue = Venue.create(name:                 fields[2],
                                 database_code:        fields[0],
                                 active:               fields[1],
                                 address:              fields[3])
            if venue.errors.empty?
              puts "Created venue #{fields[2]}"
            else
              puts "Venue create failed: #{fields[2]}"
              pp venue.errors                        
            end
          end
        end
      end
    end
  
    desc 'Load / update sports table into the database'
    task load_sports: ['db/data/sport.csv', 'db:migrate'] do |t|
        puts 'Loading sports...'

        user = User.first

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
                    sport.updated_by = user.id
                    if sport.save
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
                              court_name:                fields[7],
                              updated_by:                user.id)
                    if sport.errors.empty?
                        puts "Created sport #{fields[0]}"
                    else
                        puts "Sport create failed: #{fields[0]}"
                        pp sport.errors                        
                    end
                end
            end
        end
    end
end
