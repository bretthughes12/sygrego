namespace :syg do
    require 'csv'
    require 'pp'

    desc 'Initialise groups for new year'
    task initialise_groups: ['db:migrate'] do |t|
      puts 'Initialising groups for new year...'

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

    desc 'Migrate volunteer section_id to sections'
    task migrate_volunteer_sections: ['db:migrate'] do |t|
      puts 'Updating volunteer sections to has and belongs to many association...'

      migrate_count = 0

      Volunteer.all.each do |volunteer|
        unless volunteer.section_id.nil? 
          section = Section.find(volunteer.section_id)

          volunteer.sections << section
          puts "#{volunteer.name} -> #{section.name}"

          migrate_count += 1
        end
      end

      puts "Volunteer sections updated - #{migrate_count}"
    end

    desc 'Update medicare option on Mysyg Settings'
    task update_medicare_option: ['db:migrate'] do |t|
      puts 'Updating medicare options...'

      count = 0

      MysygSetting.all.each do |ms|
        if ms.require_medical
          ms.medicare_option = 'Require'
          ms.save
          count += 1

          puts ">>> #{ms.group.short_name} set to Require"
        end
      end

      puts "Options updated - #{count}"
    end

    desc 'Blank out encrypted fields in users'
    task blank_encrypted_users_fields: ['db:migrate'] do |t|
      puts 'Setting WWCC number to nil for Users...'

      count = 0

      User.all.each do |u|
        u.wwcc_number = nil
        u.save
        count += 1
      end

      puts "Users updated - #{count}"
    end

    desc 'Blank out encrypted fields in participants'
    task blank_encrypted_participants_fields: ['db:migrate'] do |t|
      puts 'Setting WWCC number and Medicare number to nil for Participants...'

      count = 0
      errors = 0

      Participant.all.each do |p|
        if p.age > 17
          p.wwcc_number = 'TBC'
        else
          p.wwcc_number = nil
        end
        p.medicare_number = nil
        if p.save(validate: false)
          count += 1
        else
          errors += 1
          pp p.errors
        end
      end

      puts "Participants updated - #{count}"
      puts "Participants not updated - #{errors}"
    end

    desc 'Populate mobile phone number in participants'
    task populate_mobile_phone: ['db:migrate'] do |t|
      puts 'Populating mobile number for Participants...'

      count = 0
      errors = 0
      skips = 0

      Participant.all.each do |p|
        if p.mobile_phone_number.nil?
          unless p.phone_number.nil?
            p.mobile_phone_number = p.phone_number
          else
            p.mobile_phone_number = 'Unknown'
          end
          if p.save(validate: false)
            count += 1
          else
            errors += 1
            pp p.errors
          end
        else
          skips += 1
        end
      end

      puts "Participants updated - #{count}"
      puts "Participants not updated - #{errors}"
      puts "Participants skipped - #{skips}"
    end

    desc 'Populate draw_type in sections from sports'
    task populate_section_draw_types: ['db:migrate'] do |t|
      puts 'Updating draw types...'

      count = 0

      Section.all.each do |s|
        s.draw_type = s.sport.draw_type
        s.save

        count += 1
      end

      puts "Sections updated - #{count}"
    end
end