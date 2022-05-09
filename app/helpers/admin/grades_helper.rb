module Admin::GradesHelper
    def grade_display_class(grade)
      case 
      when grade.over_limit?
        'table-danger'
      when grade.one_entry_per_group?
        'table-warning'
      else
        'table-primary'
      end
    end

    def grade_filtered(grade, group)
        if GroupsGradesFilter.exists?(grade_id: grade.id, group_id: group.id)
          'table-dark'
        else
          'table-primary'
        end
    end
end
