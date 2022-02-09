namespace :syg do
    require 'csv'
    require 'pp'

    desc 'Initialise groups for new year'
    task initialise_groups: ['db:migrate'] do |t|
      puts 'Initialising groups for new year...'

      user = User.first
      group_count = 0

      Group.order(:abbr).load.each do |group|
        group.status = 'Stale' unless group.admin_use
        group.last_year = group.coming
        group.coming = false unless group.admin_use
        group.new_group = false
        group.save
        group_count += 1
      end

      puts "Groups initialised - #{group_count}"
    end

    desc 'Initialise participants for new year'
    task initialise_participants: ['db:migrate'] do |t|
      puts 'Initialising participants for new year...'

      user = User.first
      participant_count = 0
      error_count = 0

      Participant.all.each do |participant|
        participant.coming = false
        participant.helper = false
        participant.group_coord = false
        participant.sport_coord = false
        participant.guest = false
        participant.withdrawn = false
        participant.fee_when_withdrawn = 0.0
        participant.late_fee_charged = false
        participant.early_bird = false
        participant.amount_paid = 0.0
        participant.driver = false
        participant.driver_signature = false
        participant.driver_signature_date = nil
        participant.years_attended = nil if participant.years_attended = 0
        participant.updated_by = user.id
        if participant.save
          participant_count += 1
        else
          error_count += 1
          if error_count < 5
            pp participant.errors
          end
        end
      end

      puts "Participants initialised - #{participant_count}; errors - #{error_count}"
    end

    desc 'Create default event details'
    task create_event_details: ['db:migrate'] do |t|
      puts 'Creating event details for all groups...'

      user = User.first
      event_count = 0

      Group.all.each do |group|
        if group.event_detail.nil?
          EventDetail.create(
            group_id: group.id,  
            onsite: true,
            estimated_numbers: 20,
            number_of_vehicles: 0,
            buddy_interest: "Not interested"
          )
          event_count += 1
        end
      end

      puts "Event details created - #{event_count}"
    end
end