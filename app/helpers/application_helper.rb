module ApplicationHelper

    def title(title)
        content_for(:title) { title }
    end
    
    def primary_button_class
        "btn btn-primary btn-sm"
    end
    
    def danger_button_class
        "btn btn-danger btn-sm"
    end
    
    def search_box(path, label)
        render :partial => '/application/search_box', 
               :locals => {:path => path, :label => label}    
    end
    
end
