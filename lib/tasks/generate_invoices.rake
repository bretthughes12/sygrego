# frozen_string_literal: true

namespace :syg do
  desc 'Generate and attach an invoice'
  task generate_test_invoice: ['db:migrate'] do |_t|
    group = Group.where(abbr: "ADM").first
    payments = group.payments.order(:paid_at).load
    pdf = FinanceReport.new.add_data(group, payments).to_pdf
    file = Tempfile.new(['file', '.pdf'], Rails.root.join('tmp'))
    file.binmode
    file.write(pdf)
    file.rewind
    file.close

    puts file.path

    group.invoice2_file.purge if group.invoice2_file.attached?
    group.invoice2_file.attach(io: File.open(file.path), 
      filename: "Invoice2.pdf",
      content_type: 'application/pdf',
      identify: false)
  end
end