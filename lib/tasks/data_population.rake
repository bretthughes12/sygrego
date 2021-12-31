namespace :syg do
    require 'csv'
    require 'pp'

    desc 'Make all groups stale'
    task make_groups_stale: ['db:migrate'] do |t|
      puts 'Updating groups - setting to stale...'

      user = User.first
      group_count = 0

      Group.all.each do |group|
        group.status = 'Stale'
        group.save
        group_count += 1
      end

      puts "Groups updated - #{group_count}"
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