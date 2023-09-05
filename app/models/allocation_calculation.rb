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
      factor
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
  