module Admin::SportPreferencesHelper

    def sport_pref_class(pref)
        case 
          when pref.is_entered_this_sport?
            "table-primary"
          else
            "table-secondary"
        end
    end
end
