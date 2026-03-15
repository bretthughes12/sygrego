prawn_document(filename: "volunteers.pdf", disposition: "attachment", type: 'application/pdf') do |pdf|
  pdf.text "SYG #{@settings.this_year} Volunteer Details", size: 15, style: :bold

  @volunteers.each do |volunteer|
    report = [
      ["Title", volunteer.description ],
      ["Volunteer Type", volunteer.volunteer_type.name ],
      ["Department", volunteer.volunteer_type.department ],
      ["Database Code", volunteer.volunteer_type.database_code ],
      ["Description", volunteer.volunteer_type.description ],
      ["T-Shirt", volunteer.t_shirt.to_s ],
      ["Age Category", volunteer.age_category ],
      ["Sport Related", volunteer.volunteer_type.sport_related.to_s ],
      ["Send Emails", volunteer.send_volunteer_email.to_s ],
      ["CC email", volunteer.cc_email ],
      ["Email strategy", volunteer.email_strategy ],
      ["Email template", volunteer.email_template ]
    ]

    pdf.table(report, column_widths: [188, 335]) do
      columns(0).background_color = 'AAAAAA'
    end

    pdf.move_down(10)
    pdf.stroke_horizontal_rule
    pdf.move_down(10)
  end
end