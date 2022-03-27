namespace :syg do
  require 'csv'

  desc 'Create a statistics record'
  task record_statistics: ['environment'] do |_t|
    groups = Group.not_admin.coming.count
    participants = Participant.coming.accepted.count
    sport_entries = SportEntry.count
    volunteer_vacancies = Volunteer.unfilled.count

    settings = Setting.first
    weeks_to_syg = ((settings.first_day_of_syg.amjd().to_f - DateTime.now.amjd().to_f) / 7).to_i + 1

    Statistic.create(number_of_groups: groups,
                      number_of_participants: participants,
                      number_of_sport_entries: sport_entries,
                      number_of_volunteer_vacancies: volunteer_vacancies,
                      weeks_to_syg: weeks_to_syg,
                      year: settings.this_year)
  end

  desc 'Create a statistics record for the weekly run'
  task record_statistics_on_monday_nights: ['environment'] do |_t|
    now = Time.now
    if now.monday?
      settings = Setting.first

      if settings.generate_stats
        Rake::Task['syg:record_statistics'].execute
        puts 'Statistics recorded'
      else
        puts 'No statistics recorded, as the flag is not set'
      end
    else
      puts 'No statistics recorded, as it is not Monday night'
    end
  end

  desc 'Load past statistics into the database'
  task load_statistics: ['db/data/statistics.csv', 'db:migrate'] do |t|
    puts 'Loading statistics...'

    CSV.foreach(t.prerequisites.first) do |fields|
      if fields[0] != 'Date'
        Statistic.create(
          year: fields[1].to_i,
          weeks_to_syg: fields[2].to_i,
          number_of_groups: fields[3].to_i,
          number_of_participants: fields[4].to_i,
          number_of_sport_entries: fields[5].to_i,
          number_of_volunteer_vacancies: fields[6].to_i
        )
      end
    end
  end
end
  