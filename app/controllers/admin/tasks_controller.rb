class Admin::TasksController < ApplicationController
    before_action :authenticate_user!

    layout 'admin'

    # POST /admin/tasks/allocate_restricted
    def allocate_restricted
        if !@settings.restricted_sports_allocated
          Admin::TasksController.do_allocate(current_user)
          set_restricted_sports_allocated_setting
          flash[:notice] = 'Restricted sports allocation is under way. Look for an email when finished'
        else
          flash[:notice] = 'ERROR - Restricted sports are already allocated'
        end
        
        redirect_to summary_admin_ballot_results_path 
    end
      
    # POST /admin/tasks/allocate_team_grades_to_sections
    def allocate_team_grades_to_sections
        if !@settings.team_draws_complete
          Admin::TasksController.delay.do_team_grade_allocation(current_user)
          flash[:notice] = 'Allocation of team grades to sections is under way. Look for an email when finished'
        else
          flash[:notice] = 'ERROR - Team grades are already allocated to sections'
        end
        
        redirect_to grades_path(option: :grade_allocation)
    end
      
    # POST /admin/tasks/allocate_indiv_grades_to_sections
    def allocate_indiv_grades_to_sections
        if !@settings.indiv_draws_complete
          Admin::TasksController.delay.do_indiv_grade_allocation(current_user)
          flash[:notice] = 'Allocation of individual grades to sections is under way. Look for an email when finished'
        else
          flash[:notice] = 'ERROR - Individual grades are already allocated to sections'
        end
        
        redirect_to grades_path(option: :grade_allocation)
    end
    
    private
    
    def set_restricted_sports_allocated_setting
        @settings.restricted_sports_allocated = true
        @settings.save(validate: false)
    end
    
    def self.do_allocate(current_user)
        empty_ballot_results
        reset_all_restricted_entries_to_requested
        close_grades_with_entry_limits(current_user)    
        reject_2nd_entries_in_grades_over_limits(current_user)
        allocate_entries_in_grades_under_limits(current_user)
        allocate_1st_entries_in_grades_over_limits(current_user)
        initialise_allocation_bonuses
        allocate_grades_with_ballots(current_user)
        TasksMailer.allocations_done.deliver_now
    end
      
    def self.empty_ballot_results
        logger.info("Emptying the ballot results report from last time...")
        BallotResult.destroy_all
    end
    
    def self.reset_all_restricted_entries_to_requested
        logger.info("Resetting all entry statuses to 'Requested'...")
        Grade.reset_all_restricted_entries_to_requested!
    end
    
    def self.close_grades_with_entry_limits(current_user)
        logger.info("Closing all restricted grades...")
        Grade.accepting.restricted.each do |g| 
          g.close!
        end
    end
    
    def self.reject_2nd_entries_in_grades_over_limits(current_user)
        logger.info("Rejecting low priority entries for groups where #groups greater or equal limits...")
        Grade.over_limit.ballot_for_high_priority.each do |g|
          g.sport_entries.requested.each do |e| 
            e.reject! if !e.high_priority
          end
        end
    end
    
    def self.allocate_entries_in_grades_under_limits(current_user)
        logger.info("Allocating entries for grades not over limits...")
        Grade.not_over_limit.each do |g|
          g.sport_entries.requested.each do |e| 
            e.enter!
          end
        end
    end
    
    def self.allocate_1st_entries_in_grades_over_limits(current_user)
        logger.info("Allocating high priority entries for groups where #groups not over limits...")
        Grade.over_limit.ballot_for_low_priority.each do |g|
          g.sport_entries.requested.each do |e| 
            e.require_confirmation! if e.high_priority
          end
        end
    end
      
    def self.initialise_allocation_bonuses
        logger.info("Initialising allocation bonuses...")
        Group.with_bonus.each { |g| g.reset_allocation_bonus! }
    end
    
    def self.allocate_grades_with_ballots(current_user)
        logger.info("Allocating all remaining requested sport entries by ballot for each grade...")
    
        # Collect all of the allocation factors in the one place
        factor_hash = {}
        logger.info("... collecting allocation factors")
    
    #      Grade.where(sport_session_id: s.id).over_limit.each do |g| 
    #        factor_hash[g.id] = g.requested_entry_factors
    #      end
          
        # Do the allocations
        Grade.over_limit.each do |g| 
            logger.info("... Allocating #{g.name}...")
            
            # Perform the ballot
            allocated = {}
            missed_out = {}
            g.allocate_requested_entries_by_ballot(allocated, missed_out)
            
            # Report all allocated entries
            allocated.each do |e|
                entry = SportEntry.find(e[0])
                result = BallotResult.new(
                  :sport_name => g.sport.name,
                  :grade_name => g.name,
                  :entry_limit => g.entry_limit,
                  :over_limit => g.over_limit, 
                  :one_entry_per_group => g.one_entry_per_group, 
                  :group_name => entry.group.short_name,
                  :new_group => entry.group.new_group,
                  :sport_entry_name => entry.name, 
                  :sport_entry_status => entry.status, 
                  :factor => e[1])
                result.save(:validate => false)
            end
        
            # Report all rejected entries
            missed_out.each do |e|
                entry = SportEntry.find(e[0])
                result = BallotResult.new(
                  :sport_name => g.sport.name,
                  :grade_name => g.name,
                  :entry_limit => g.entry_limit,
                  :over_limit => g.over_limit, 
                  :one_entry_per_group => g.one_entry_per_group, 
                  :group_name => entry.group.short_name,
                  :new_group => entry.group.new_group,
                  :sport_entry_name => entry.name, 
                  :sport_entry_status => entry.status, 
                  :factor => e[1])
                result.save(:validate => false)
            end
        end
    end
    
    def self.do_team_grade_allocation(current_user)
        divisions = Group.group_divisions
        
        Grade.team.active.closed.each do |grade|
          allocate_grade_to_sections(grade, divisions, current_user)
        end
    
        TasksMailer.grade_allocations_done.deliver_now
    end
    
    def self.do_indiv_grade_allocation(current_user)
        divisions = Group.group_divisions
        
        Grade.individual.active.closed.each do |grade|
          allocate_grade_to_sections(grade, divisions, current_user)
        end
    
        TasksMailer.grade_allocations_done.deliver_now
    end
    
    def self.allocate_grade_to_sections(grade, divisions, current_user)
        if grade.sport_entries.entered.count > 0
          case
            when grade.sections.active.count == 1
              assign_all_sport_entries_to_section(grade, current_user)
     
            when grade.sections.active.count > 1
              initialise_all_sections(grade)
              assign_all_entries_for_coordinating_group(grade, current_user)
              set_number_in_draw_for_all_sections(grade, current_user)
              entries = accumulate_entries_into_divisions(grade, divisions)
              assign_entries_to_sections(grade, entries, current_user)
              
            # else do nothing
          end
        end
        
        grade.status = "Allocated"
        grade.entry_limit = grade.sport_entries.entered.count
        grade.save(validate: false)
    end
    
    def self.assign_all_sport_entries_to_section(grade, current_user)
        section = grade.sections.active.first
        section.number_in_draw = grade.sport_entries.entered.count
        section.save(validate: false)
        
        grade.sport_entries.entered.each do |entry|
          entry.section_id = section.id
          entry.save(validate: false)
        end
    end
    
    def self.initialise_all_sections(grade)
        grade.sport_entries.entered.each do |entry|
          entry.section_id = nil
          entry.save(validate: false)
        end
    end
    
    def self.assign_all_entries_for_coordinating_group(grade, current_user)
        grade.sections.active.each do |section|
          officials = section.sport_coords
          
          officials.each do |official|
            if official.participant
              group_id = official.participant.group.id
              
              entries = grade.sport_entries.where(group_id: group_id)
    
              entries.each do |entry|
                entry.section_id = section.id
                entry.save(validate: false)
              end
            end
          end
        end
    end
    
    def self.set_number_in_draw_for_all_sections(grade, current_user)
        entries_remaining = grade.entries.entered.count
        courts_remaining = grade.sections.active.sum(:number_of_courts)
        
        grade.sections.active.order(:name).each do |section|
          if courts_remaining == section.number_of_courts
            section.number_in_draw = entries_remaining
          else
            section.number_in_draw = (((entries_remaining / courts_remaining * section.number_of_courts) + 1)  / 2).to_i * 2 
          end
          entries_remaining -= section.number_in_draw
          courts_remaining -= section.number_of_courts
          section.save(validate:false) 
        end
    end
    
    def self.accumulate_entries_into_divisions(grade, divisions)
        divs = Hash.new
        divs["Small Churches"] = Array.new
        divs["Medium Churches"] = Array.new
        divs["Large Churches"] = Array.new
        
        grade.sport_entries.entered.each do |entry|
          division = divisions[entry.group.id].nil? ? "Small Churches" : divisions[entry.group.id]
          if entry.section_id.nil?
            divs[division] << entry
          end
        end
        
        # Randomise the order of the entries in each array
        divs["Small Churches"].shuffle!
        divs["Medium Churches"].shuffle!
        divs["Large Churches"].shuffle!
        
        (divs["Small Churches"] + 
         divs["Medium Churches"] + 
         divs["Large Churches"]).compact
    end
    
    def self.assign_entries_to_sections(grade, entries, current_user)
        grade.sections.active.each do |section|
          number_to_go = section.number_in_draw - section.entries.count
          
          number_to_go.times do
            entry = entries.pop
            unless entry.nil?
              entry.section = section
              entry.save(validate: false)
            end
          end
        end
    end
end
