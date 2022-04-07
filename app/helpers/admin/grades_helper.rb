module Admin::GradesHelper
    def grade_display_class(grade)

    end

    def grade_filtered(grade, group)
        if GroupsGradesFilter.exists?(grade_id: grade.id, group_id: group.id)
          'table-dark'
        else
          'table-primary'
        end
    end
end
