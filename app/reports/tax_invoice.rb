class TaxInvoice < Prawn::Document
    include ReportLayout
  
    def add_data(group, payments)
        @group = group
        @payments = payments
#        @charges = charges
      
        self
    end
    
    def to_pdf
        @settings = Setting.first
    
        report_header("Tax Invoice")
        report_content
    
        render
    end
    
    private
    
    def report_content
        include_summary_table
#        include_charges_table
        include_payment_table
        show_total_owing
        show_payment_options
    end
  
    def include_summary_table
      heading2 "Participant Fees"
      
      summary = [
        [ "Deposit", helpers.number_to_currency(@group.deposit) ],
        [ "Total remaining fees", helpers.number_to_currency(@group.fees) ]
        ]
      
      summary << [ "Late fees", helpers.number_to_currency(@group.late_fees) ] if @group.late_fees
#      summary << [ "Other charges", helpers.number_to_currency(@group.other_charges) ] 
      
      table(summary, :column_widths => [450, 85]) do
        columns(1).align = :right
      end
  
      total = [
        [ "Total" , helpers.number_to_currency(@group.total_amount_payable) ]
        ]
      
      table(total, :column_widths => [450, 85], :row_colors => ['DDDDDD']) do
        columns(1).align = :right
      end 
      
      gst = [
        [ "* GST included in Total" , helpers.number_to_currency((@group.total_amount_payable) / 11) ]
        ]
      
      font_size(9)
      
      table(gst, :column_widths => [450, 85]) do
        columns(1).align = :right
      end
      
      font_size(12)
          
      move_down(10)
    end
  
#    def include_charges_table
#      heading2 "Other Charges"
      
#      charges = [["Date Paid", "Reason", "Amount"]]
#      charges += @charges.map do |p|
#        [
#          p.paid_at ? p.paid_at.in_time_zone.strftime("%d/%m/%Y") : "",
#          p.description,
#          helpers.number_to_currency(p.relative_amount)
#        ]
#      end
      
#      unless @charges.empty? 
#        table(charges, :column_widths => [100, 350, 85]) do 
#          row(0).background_color = 'AAAAAA' 
#          columns(2).align = :right
#        end
#      end
      
#      charge = [
#        [ "Total other charges", helpers.number_to_currency(@group.other_charges) ]
#        ]
      
#      table charge, :column_widths => [450, 85], :row_colors => ['DDDDDD'] do
#        columns(1).align = :right
#      end
      
#      move_down(10)
#    end
  
    def include_payment_table
      heading2 "Payments Recorded"
      
      payments = [["Type", "Date Paid", "Name", "Amount"]]
      payments += @payments.map do |p|
        [
          p.payment_type,
          p.paid_at ? p.paid_at.in_time_zone.strftime("%d/%m/%Y") : "",
          p.name,
          helpers.number_to_currency(p.amount)
        ]
      end
      
      unless @payments.empty? 
        table(payments, :column_widths => [100, 100, 250, 85]) do 
          row(0).background_color = 'AAAAAA' 
          columns(3).align = :right
        end
      end
      
      paid = [
        [ "Total payments recorded", helpers.number_to_currency(@group.amount_paid) ]
        ]
      
      table paid, :column_widths => [450, 85], :row_colors => ['DDDDDD'] do
        columns(1).align = :right
      end
      
      move_down(10)
    end
      
    def show_total_owing
      heading2 "Total Owing"
      
      owing = [
        [ "Total owing", helpers.number_to_currency(@group.amount_outstanding) ]
        ]
      
      table owing, :column_widths => [450, 85], :row_colors => ['DDDDDD'] do
        columns(1).align = :right
      end
    end
      
    def show_payment_options
      if @group.amount_outstanding > 0
        move_down(20)
        
        heading2 "Payment Options"
      
        move_down(10)
      
        heading3 "Direct Deposit", 14
        text "Account Name: #{APP_CONFIG[:cheque_payable]}"
        text "BSB: #{Rails.application.credentials.account_bsb}"
        text "Account: #{Rails.application.credentials.account_number}"
        text "Reference: SYG#{@settings.this_year.to_s + @group.abbr}"
      end
    end
  end