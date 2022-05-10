class Admin::TasksController < ApplicationController
    before_action :authenticate_user!

    layout 'admin'

    # POST /admin/tasks/allocate_restricted
    def allocate_restricted
        if !@settings.restricted_sports_allocated
          AllocateRestrictedJob.perform_later
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
