namespace :syg do
  desc "Anonymise data in the database for non-Production use"
  task anonymise_data: ['db:migrate'] do |_t|
    puts "Anonymising participant data..."
    participant_updates = 0
    participant_errors = 0
    Participant.find_each do |participant|
      if participant.anonymise!
        participant_updates += 1
      else
        participant_errors += 1
      end
    end

    puts "Anonymising user data..."
    user_updates = 0
    user_errors = 0
    User.find_each do |user|
      if user.anonymise!
        user_updates += 1
      else
        user_errors += 1
      end
    end

    puts "Anonymising group data..."
    group_updates = 0
    group_errors = 0
    Group.find_each do |group|
      if group.anonymise!
        group_updates += 1
      else
        group_errors += 1
      end
    end

    puts "Anonymising volunteer data..."
    volunteer_updates = 0
    volunteer_errors = 0
    Volunteer.find_each do |volunteer|
      if volunteer.anonymise!
        volunteer_updates += 1
      else
        volunteer_errors += 1
      end
    end

    puts "Data anonymisation complete."
    puts ">> Participant updates: #{participant_updates}, errors: #{participant_errors}"
    puts ">> User updates: #{user_updates}, errors: #{user_errors}"
    puts ">> Group updates: #{group_updates}, errors: #{group_errors}"
    puts ">> Volunteer updates: #{volunteer_updates}, errors: #{volunteer_errors}"
  end
end