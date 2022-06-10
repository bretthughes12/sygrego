prawn_document(filename: "incident_reports.pdf", disposition: "attachment", type: 'application/pdf') do |pdf|
  pdf.text "SYG #{@settings.this_year} Incident Reports", size: 15, style: :bold

  @incident_reports.each do |incident|
    report = [
      ["Section", incident.section ],
      ["Session", incident.session ],
      ["Venue", incident.venue ],
      ["Description", incident.description ],
      ["Name and group", incident.name ],
      ["Action taken", incident.action_taken ],
      ["Any other info", incident.other_info ]
    ]

    pdf.table(report, column_widths: [188, 335]) do
      columns(0).background_color = 'AAAAAA'
    end

    pdf.move_down(10)
    pdf.stroke_horizontal_rule
    pdf.move_down(10)
  end
end