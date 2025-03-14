module Admin::GradesHelper
    def grade_display_class(grade)
      case 
      when grade.one_entry_per_group?
        'table-warning'
      when grade.over_limit?
        'table-danger'
      else
        'table-primary'
      end
    end
end
