module ReportLayout

    def report_header(title)
        image "#{Rails.root.join('app/assets/images/syg.jpg')}", :position => :center, :scale => 0.75
        image "#{Rails.root.join('app/assets/images/youth_vision.jpg')}", :position => :right, :vposition => 0, :scale => 0.13
        draw_text "A.B.N. #{APP_CONFIG[:abn]}", :size => 6, :at => [478,665] unless APP_CONFIG[:abn].nil?
        draw_text "Date: #{Time.now.in_time_zone.strftime("%d/%m/%Y")}", :size => 16, :style => :bold, :at => [415,640]
        
        heading1 "State Youth Games #{APP_CONFIG[:this_year]}", 30
        heading1 "#{@group.name}"
    
        stroke_horizontal_rule
        move_down(10)
    end
    
    def paragraph(content, size = 10)
      text content, size: size
      move_down(10)
    end
    
    def heading1(content, size = 24)
      text content, style: :bold, size: size, align: :center
      move_down(10)
    end
    
    def heading2(content, size = 16)
      text content, style: :bold, size: size
      move_down(10)
    end
    
    def heading3(content, size = 10)
      text content, style: :bold, size: size
    end
  
    def form_field(label, start=75, length=200)
      text label
      stroke_horizontal_line start, length
      move_down(5)
    end
    
    private
    
    def helpers
      ActionController::Base.helpers
    end
  end