# frozen_string_literal: true

namespace :syg do
    require 'csv'
    require 'pp'

    desc 'Load / update sport sessions table into the database'
    task load_sessions: ['db/data/sport_session.csv', 'db:migrate'] do |t|
      puts 'Loading sport sessions...'

      user = User.first
      file = File.new(t.prerequisites.first)

      result = Session.import(file, user)

      puts "Sessions imported - #{result[:creates]} added; #{result[:updates]} updated; #{result[:errors]} errors"

      result[:error_list].each do |e|
        puts "Session: #{e.name}"
        pp e.errors
      end
  end
  
    desc 'Load / update sport venues table into the database'
    task load_venues: ['db/data/sport_venue.csv', 'db:migrate'] do |t|
      puts 'Loading sport venues...'

      user = User.first
      file = File.new(t.prerequisites.first)

      result = Venue.import(file, user)

      puts "Venues imported - #{result[:creates]} added; #{result[:updates]} updated; #{result[:errors]} errors"

      result[:error_list].each do |e|
        puts "Venue: #{e.name}"
        pp e.errors
      end
  end
  
    desc 'Load / update sports table into the database'
    task load_sports: ['db/data/sport.csv', 'db:migrate'] do |t|
        puts 'Loading sports...'

        user = User.first
        file = File.new(t.prerequisites.first)

        result = Sport.import(file, user)
  
        puts "Sports imported - #{result[:creates]} added; #{result[:updates]} updated; #{result[:errors]} errors"

        result[:error_list].each do |e|
          puts "Sport: #{e.name}"
          pp e.errors
        end
    end
  
    desc 'Load / update sport grades table into the database'
    task load_grades: ['db/data/sport_grade.csv', 'db:migrate'] do |t|
        puts 'Loading sport grades...'

        user = User.first
        file = File.new(t.prerequisites.first)

        result = Grade.import(file, user)
  
        puts "Grades imported - #{result[:creates]} added; #{result[:updates]} updated; #{result[:errors]} errors"

        result[:error_list].each do |e|
          puts "Grade: #{e.name}"
          pp e.errors
        end
    end
  
    desc 'Load / update sport sections table into the database'
    task load_sections: ['db/data/sport_section.csv', 'db:migrate'] do |t|
        puts 'Loading sport sections...'

        user = User.first
        file = File.new(t.prerequisites.first)

        result = Section.import(file, user)
  
        puts "Sections imported - #{result[:creates]} added; #{result[:updates]} updated; #{result[:errors]} errors"
    end

    desc 'Load / update volunteer types table into the database'
    task load_volunteer_types: ['db/data/volunteer_type.csv', 'db:migrate'] do |t|
      puts 'Loading volunteer types...'

      user = User.first
      file = File.new(t.prerequisites.first)

      result = VolunteerType.import(file, user)

      puts "Volunteer Types imported - #{result[:creates]} added; #{result[:updates]} updated; #{result[:errors]} errors"

      result[:error_list].each do |e|
        puts "Volunteer Type: #{e.name}"
        pp e.errors
      end
  end
end
