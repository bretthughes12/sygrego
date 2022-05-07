class AllocationCalculation
    attr_accessor :high_priority
  
    def initialize(entry)
      @entry = entry
      @group = entry.group
      @grade = entry.grade
      @entries_in_grade = SportEntry.requested
                                    .where(['grade_id = ?', @entry.grade_id])
                                    .load
      @high_priority_entries_in_grade = @grade.high_priority_entries
      @settings = Setting.first
    end
  
    def allocation_factor
      factor = entry_base_allocation_factor
      factor += @settings.sport_coord_sports_allocation_factor if @grade.coordinators_groups.include?(@group)
      (factor * group_priority_factor.to_f).ceil
    end
  
    def allocation_chance
      # collect all allocation factors of other entries in the grade into an array
      # (sorted in descending order)
      entries = if @high_priority
                  @high_priority_entries_in_grade - [@entry]
                else
                  @entries_in_grade - @high_priority_entries_in_grade - [@entry]
                end

      factors = []
      factors = entries.collect(&:allocation_factor).sort { |x, y| y <=> x }
  
      # calculate the chance that the entry will be allocated
      ((1.0 - chance_of_not_being_allocated(factors)) * 100).floor
    end
  
    def number_of_groups_in_grade
      groups_in_grade.size
    end
  
    private
  
    def entry_base_allocation_factor
      group_base_allocation_factor
    end
  
    def group_base_allocation_factor
      @number_of_grades ||= grades_to_be_allocated_for_group.size
      factor = @number_of_grades == 0 ? 0 : (@group.participants.coming.accepted.playing_sport.size / @number_of_grades).to_i
      factor += @settings.new_group_sports_allocation_factor if @group.new_group
      [factor, 1].max
    end
  
    def group_priority_factor
      @entries_for_allocation ||= sport_entries_to_be_allocated_for_group
      @total_priority ||= @entries_for_allocation.sum(&:priority)
      @total_priority == 0 ? 1 : (@entries_for_allocation.size.to_f / @total_priority)
    end
  
    # calculate the chance that the entry will NOT be allocated
    def chance_of_not_being_allocated(factors)
      factors_remaining = factors.sum
      total_remaining = factors_remaining + allocation_factor
      entries_remaining = @grade.entries_to_be_allocated
      my_factor = 1.0
  
      factors.each do |f|
        if entries_remaining > 0
          my_factor *= factors_remaining.to_f / total_remaining
        end
        factors_remaining -= f
        total_remaining -= f
        entries_remaining -= 1
      end
      my_factor
    end
  
    def groups_in_grade
      groups = @entries_in_grade.collect(&:group)
      groups.uniq
    end
  
    def grades_to_be_allocated_for_group
      grades = []
      sport_entries_to_be_allocated_for_group.each do |e|
        grades << e.grade if e.grade.over_limit
      end
      grades.uniq
    end
  
    def sport_entries_to_be_allocated_for_group
      @group_entries_requested ||= @group.sport_entries.requested.includes(:grade)
      entries = []
      @group_entries_requested.each do |e|
        entries << e if e.grade.over_limit && (e.high_priority || !e.grade.one_entry_per_group)
      end
      entries
    end
  end
  