class TaxReceipt < Prawn::Document
    include ReportLayout
  
    def add_data(group, payments, payment)
        @group = group
        @payments = payments - [payment]
        @payment = payment
      
        self
    end
    
    def to_pdf
        @settings = Setting.first
    
        report_header("Tax Receipt", @payment)
        report_content
    
        render
    end
    
    private
    
    def report_content
        include_summary_table
        include_payment_table
        show_total_owing
    end
  
    def include_summary_table
      heading2 "Participant Fees"
      
      summary = [
        [ "Deposit", helpers.number_to_currency(@group.deposit) ],
        [ "Total remaining fees", helpers.number_to_currency(@group.fees) ]
        ]
      
      summary << [ "Late fees", helpers.number_to_currency(@group.late_fees) ] if @group.late_fees
      
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
  
    def include_payment_table
      heading2 "Payments Recorded"
      
      payments = [["Invoice", "Date Paid", "Reference", "Amount"]]
      payments += @payments.map do |p|
        [
          p.invoice_number,
          p.paid_at ? p.paid_at.in_time_zone.strftime("%d/%m/%Y") : "",
          p.reference,
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
      
      table paid, :column_widths => [450, 85] do
        columns(1).align = :right
      end

      this_payment = [
        [ "This payment", helpers.number_to_currency(@payment.amount) ]
        ]
      
      table this_payment, :column_widths => [450, 85], :row_colors => ['DDDDDD'] do
        columns(1).align = :right
      end

      move_down(10)
    end
      
    def show_total_owing
      heading2 "Total Owing"
      
      owing = [
        [ "Total owing", helpers.number_to_currency(@group.amount_outstanding - @payment.amount) ]
        ]
      
      table owing, :column_widths => [450, 85], :row_colors => ['DDDDDD'] do
        columns(1).align = :right
      end
    end
end