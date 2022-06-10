prawn_document(filename: "sport_evaluations.pdf", disposition: "attachment", type: 'application/pdf') do |pdf|
  pdf.text "SYG #{@settings.this_year} Sports Evaluation Forms", size: 15, style: :bold

  @sports_evaluations.each do |evaluation|
    report = [
      ["Sport", evaluation.sport ],
      ["Section", evaluation.section ],
      ["Session", evaluation.session ],
      ["Venue Rating", evaluation.venue_rating ],
      ["Equipment Rating", evaluation.equipment_rating ],
      ["Length of Games", evaluation.length_rating ],
      ["Umpiring Rating", evaluation.umpiring_rating ],
      ["Scoring/Recording of results", evaluation.scoring_rating ],
      ["Time allocation", evaluation.time_rating ],
      ["Support from SYG Committee", evaluation.support_rating ],
      ["Safety/First Aid", evaluation.safety_rating ],
      ["Online results", evaluation.results_rating ],
      ["What worked well", evaluation.worked_well ],
      ["What didn't work", evaluation.to_improve ],
      ["Suggestions for next year?", evaluation.suggestions ]
    ]

    pdf.table(report, column_widths: [188, 335]) do
      columns(0).background_color = 'AAAAAA'
    end

    pdf.move_down(10)
    pdf.stroke_horizontal_rule
    pdf.move_down(10)
  end
end