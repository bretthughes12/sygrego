class AllocateRestrictedJob < ApplicationJob
    queue_as :default
  
    def perform
        empty_ballot_results
        reset_all_restricted_entries_to_requested
        reset_grade_flags
        close_grades_with_entry_limits    
        reject_2nd_entries_in_grades_over_limits
        allocate_entries_in_grades_under_limits
        allocate_1st_entries_in_grades_over_limits
        initialise_allocation_bonuses
        allocate_grades_with_ballots
        TasksMailer.allocations_done.deliver_now
    end

    private

    def empty_ballot_results
        logger.info("Emptying the ballot results report from last time...")
        BallotResult.destroy_all
    end
    
    def reset_all_restricted_entries_to_requested
        logger.info("Resetting all entry statuses to 'Requested'...")
        Grade.reset_all_restricted_entries_to_requested!
    end
    
    def reset_grade_flags
        logger.info("Resetting the grade flags...")
        Grade.restricted.each do |g| 
          g.update_for_change_in_entries
        end
    end
    
    def close_grades_with_entry_limits
        logger.info("Closing all restricted grades...")
        Grade.accepting.restricted.each do |g| 
          g.close!
        end
    end
    
    def reject_2nd_entries_in_grades_over_limits
        logger.info("Rejecting low priority entries for groups where #groups greater or equal limits...")
        Grade.over_limit.ballot_for_high_priority.each do |g|
          g.sport_entries.requested.each do |e| 
            e.reject! if !e.high_priority
          end
        end
    end
    
    def allocate_entries_in_grades_under_limits
        logger.info("Allocating entries for grades not over limits...")
        Grade.not_over_limit.each do |g|
          g.sport_entries.requested.each do |e| 
            e.enter!
#            e.assign_section!
          end
        end
    end
    
    def allocate_1st_entries_in_grades_over_limits
        logger.info("Allocating high priority entries for groups where #groups not over limits...")
        Grade.over_limit.ballot_for_low_priority.each do |g|
            g.sport_entries.requested.each do |e| 
                if e.high_priority
                    e.require_confirmation!
#                    e.assign_section!
                end
            end
        end
    end
      
    def initialise_allocation_bonuses
        logger.info("Initialising allocation bonuses...")
        Group.with_bonus.each { |g| g.reset_allocation_bonus! }
    end
    
    def allocate_grades_with_ballots
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
end