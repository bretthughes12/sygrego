module Admin::GroupsHelper
    def group_display_class(group)
    
    end
 
    def group_short_name_hint(group)
        "Warning: changing this field will change your custom registration link"
#        "Warning: changing this field will change your custom registration link" if group.mysyg_enabled
    end
end
