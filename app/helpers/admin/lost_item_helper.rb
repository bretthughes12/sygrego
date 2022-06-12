module Admin::LostItemHelper
    def item_display_class(item)
      case
        when item.claimed?
          "table-primary"
        else
          "table-secondary"
      end
    end
    
    def show_lost_property
      @settings.syg_is_finished
    end
  end
  