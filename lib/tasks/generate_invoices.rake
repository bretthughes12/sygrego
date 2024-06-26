# frozen_string_literal: true

namespace :syg do
  desc 'Generate all 2nd Invoices'
  task generate_second_invoices: ['db:migrate'] do |_t|
    puts 'Generating 2nd invoices...'

    Group.coming.each do |group|
      payments = group.payments.order(:paid_at).load
      pdf = TaxInvoice.new.add_data(group, payments, "2").to_pdf
      file = Tempfile.new(['file', '.pdf'], Rails.root.join('tmp'))
      file.binmode
      file.write(pdf)
      file.rewind
      file.close

      group.invoice2_file.purge if group.invoice2_file.attached?
      group.invoice2_file.attach(io: File.open(file.path), 
        filename: "Invoice2.pdf",
        content_type: 'application/pdf',
        identify: false)
      
      puts ">>> Generated for #{group.short_name}"
    end
  end

  desc 'Generate all Final Invoices'
  task generate_final_invoices: ['db:migrate'] do |_t|
    puts 'Generating final invoices...'
    
    Group.coming.each do |group|
      payments = group.payments.order(:paid_at).load
      pdf = TaxInvoice.new.add_data(group, payments, "3").to_pdf
      file = Tempfile.new(['file', '.pdf'], Rails.root.join('tmp'))
      file.binmode
      file.write(pdf)
      file.rewind
      file.close

      group.invoice3_file.purge if group.invoice3_file.attached?
      group.invoice3_file.attach(io: File.open(file.path), 
        filename: "Invoice3.pdf",
        content_type: 'application/pdf',
        identify: false)
      
      puts ">>> Generated for #{group.short_name}"
    end
  end

  desc 'Generate and attach an invoice'
  task generate_test_invoice: ['db:migrate'] do |_t|
    group = Group.where(abbr: "ADM").first
    payments = group.payments.order(:paid_at).load
    pdf = TaxInvoice.new.add_data(group, payments, "2").to_pdf
    file = Tempfile.new(['file', '.pdf'], Rails.root.join('tmp'))
    file.binmode
    file.write(pdf)
    file.rewind
    file.close

    group.invoice2_file.purge if group.invoice2_file.attached?
    group.invoice2_file.attach(io: File.open(file.path), 
      filename: "Invoice2.pdf",
      content_type: 'application/pdf',
      identify: false)
  end
end