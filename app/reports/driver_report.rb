class DriverReport < Prawn::Document
    include ReportLayout
  
    def add_data(group, participants)
      @group = group
      @participants = participants
      
      self
    end
    
    def to_pdf
      report_header("Driver Nomination Form")
      report_content
  
      render
    end
    
    private
    
    def report_content
      include_intro_text
      include_statement_text
      create_and_include_drivers_table
      include_signoff
    end
  
    def include_intro_text
      paragraph "Over the duration of the weekend, the State Youth Games committee is extremely concerned about the safety of people on the roads while travelling to and from State Youth Games, and to the various sporting venues. We would like to bring to the attention of Group Coordinators and all drivers the following information."
      paragraph "The #{APP_CONFIG[:conference_name]}, in their CODE OF PRACTICE FOR THE PROTECTION OF CHILDREN WITHIN OUR CHURCHES, states the following concerning safe care in private motor vehicles:"
  
      heading3 "1-2-11 PRIVATE MOTOR VEHICLES"
      paragraph "All passengers including the driver must wear their seat belts. Leaders should make it their responsibility to determine, to the best of their ability, that the vehicle used is registered, the driver holds a current driver's license and is a sound driver, and that the vehicle is roadworthy. If a child is to be transported by a person other than a recognised leader, that person should have been, wherever possible, known to a leader for a reasonable period of time."
  
      heading3 "1-2-15 INSURANCE CONDITIONS OF VEHICLE"
      paragraph "The leader will need to satisfy themselves that the vehicle to be driven has correct current minimum third party insurance and property insurance."
      paragraph "Following on from this, we would ask all drivers that will be driving over the weekend to sign the attached statement. These are either to be returned with the Church registration form, or to be handed in to the State Youth Games Administration Office no later than the Friday evening of the Games. Only those drivers that do this will be able to drive over the weekend of the Games."
  
      stroke_horizontal_rule
      move_down(10)
    end
      
    def include_statement_text
      heading3 "STATEMENT"
      paragraph "I will be driving a car which will be in a roadworthy condition, and have current registration. This vehicle has current minimum third party insurance and property insurance."
      paragraph "I will ensure that both myself and all my passengers will be wearing seatbelts, and I will drive in a safe manner according to the local road conditions and traffic laws. I have read and understand the excerpts from the CODE OF PRACTICE FOR THE PROTECTION OF CHILDREN WITHIN OUR CHURCHES."
      paragraph "In the event of a motor vehicle accident occurring, I will not hold the State Youth Games Committee, or Youth Vision #{APP_CONFIG[:state_name]} responsible for any injury or damage that may result, either to myself, to other people, or to any property."
    end
       
    def create_and_include_drivers_table 
      drivers = [["Name", "Number Plate", "Signed", "Date"]]
      
      drivers += @participants.map do |d|
        [
          d.name,
          d.number_plate,
          d.driver_sign,
          d.date_driver_signed
        ]
      end
      
      empty_row = [[" "," "," "," "]]
      drivers += empty_row * 6
      
      table drivers, 
          :column_widths => { 0 => 130, 1 => 100, 2 => 100, 3 => 75 } do
        row(0).background_color = 'AAAAAA' 
      end
      
      move_down(10)
    end
    
    def include_signoff
      heading2 "Group Coordinator Details"
      form_field "Name:"
      form_field "Date:"
      form_field "Signed:"
    end
end