module Admin::SportPreferencesHelper

    def sport_pref_class(pref)
        case 
          when pref.is_entered?
            "table-primary"
          when pref.is_entered_this_sport?
            "table-warning"
          else
            "table-secondary"
        end
    end
end
