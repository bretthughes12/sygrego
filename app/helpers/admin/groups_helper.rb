module Admin::GroupsHelper
    def group_display_class(group)
      case
      when group.coming && group.event_detail.onsite
        "table-primary"
      when group.coming
        "table-warning"
      else
        "table-dark"
      end
    end
 
    def group_short_name_hint(group)
        "Warning: changing this field will change your custom registration link"
    end
end
