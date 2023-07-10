class Gc::GroupsGradesFiltersController < GcController

    def hide_team
        @mysyg_setting = MysygSetting.find(params[:id])

        filter = GroupsGradesFilter.new(group_id: params[:group_id], grade_id: params[:grade_id])
        filter.save if filter.valid?
    
        respond_to do |format|
            format.html { redirect_to(edit_team_sports_gc_mysyg_setting_path(@mysyg_setting)) }
        end
    end
  
    def hide_indiv
        @mysyg_setting = MysygSetting.find(params[:id])

        filter = GroupsGradesFilter.new(group_id: params[:group_id], grade_id: params[:grade_id])
        filter.save if filter.valid?
    
        respond_to do |format|
            format.html { redirect_to(edit_indiv_sports_gc_mysyg_setting_path(@mysyg_setting)) }
        end
    end
  
    def show_team
        @mysyg_setting = MysygSetting.find(params[:id])

        filter = GroupsGradesFilter.find_by_group_id_and_grade_id(params[:group_id], params[:grade_id])
        filter.delete if filter
        
        respond_to do |format|
            format.html { redirect_to(edit_team_sports_gc_mysyg_setting_path(@mysyg_setting)) }
        end
    end
  
    def show_indiv
        @mysyg_setting = MysygSetting.find(params[:id])

        filter = GroupsGradesFilter.find_by_group_id_and_grade_id(params[:group_id], params[:grade_id])
        filter.delete if filter
        
        respond_to do |format|
            format.html { redirect_to(edit_indiv_sports_gc_mysyg_setting_path(@mysyg_setting)) }
        end
    end
end
  