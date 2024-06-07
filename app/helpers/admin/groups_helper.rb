module Admin::GroupsHelper
    def group_submission_class(group)
      case
      when group.status == "Submitted"
        "table-warning"
      else
        "table-primary"
      end
    end
 
    def group_display_class(group)
      case
      when group.status == 'Stale'
        "table-dark"
      when group.coming && group.event_detail.onsite
        "table-primary"
      when group.coming
        "table-warning"
      else
        "table-secondary"
      end
    end
 
    def mysyg_settings_display_class(ms)
      case
      when ms.mysyg_open
        "table-primary"
      when ms.mysyg_enabled
        "table-warning"
      else
        "table-dark"
      end
    end
 
    def rego_display_class(rc)
      case
      when rc.registered
        "table-primary"
      else
        "table-dark"
      end
    end
 
    def rego_site_display_class(rc)
      case
      when rc.site_check_status == "Passed"
        "table-primary"
      when rc.site_check_status == "Recheck required"
        "table-warning"
      else
        "table-dark"
      end
    end
 
    def sport_oversubscribed_class(group, session_id)
      group.number_playing_sport >= group.participants_needed_for_session(session_id) ? 'table-primary' : 'table-danger'
    end
 
    def u18_oversubscribed_class(group, session_id)
      group.under_18s_playing_sport >= group.under_18s_needed_for_session(session_id) ? 'table-primary' : 'table-danger'
    end
  
    def group_short_name_hint(group)
        "Warning: changing this field will change your custom registration link"
    end
end
