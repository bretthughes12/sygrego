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
      ["Send Emails", volunteer.to_receive_emails?.to_s ],
      ["Email strategy", volunteer.email_strategy ],
      ["CC email", volunteer.email_who_to_cc ],
      ["Email template", volunteer.email_template_to_use ]
    ]

    pdf.table(report, column_widths: [188, 335]) do
      columns(0).background_color = 'AAAAAA'
    end

    if volunteer.to_receive_emails?
      pdf.move_down(10)
      pdf.text "Email content", size: 12, style: :bold
      if volunteer.email_template_to_use == "Default"
        pdf.text "Role: #{volunteer.description}", size: 10, style: :bold
        unless volunteer.session_name == "(not session-specific)"
          pdf.text "Session: #{volunteer.session_name}", size: 10, style: :bold
        end
        unless volunteer.venue_name == "(not venue-specific)"
          pdf.text "Venue: #{volunteer.venue_name}", size: 10, style: :bold
        end

        pdf.move_down(10)
        pdf.text "Hi SYG volunteer!", size: 10
        pdf.move_down(10)
        pdf.text "Note: You may be receiving this as a Group Co-ordinator of the intended volunteer, if the volunteer does not have an email address recorded in the SYG Registrations system. If that is the case, please pass this email on to the actual volunteer.", size: 10, style: :italic

        pdf.move_down(10)
        unless volunteer.volunteer_type.instructions.blank?
          pdf.text volunteer.volunteer_type.instructions.to_plain_text, size: 10
        end

        pdf.move_down(10)
        unless volunteer.instructions.blank?
          pdf.text volunteer.instructions.to_plain_text, size: 10
        end

        pdf.move_down(10)
        unless volunteer.volunteer_type.signature.blank?
          pdf.text volunteer.volunteer_type.signature.to_plain_text, size: 10
        end
      elsif volunteer.email_template_to_use == "Override"
        pdf.text "Role: #{volunteer.description}", size: 10, style: :bold
        unless volunteer.session_name == "(not session-specific)"
          pdf.text "Session: #{volunteer.session_name}", size: 10, style: :bold
        end
        unless volunteer.venue_name == "(not venue-specific)"
          pdf.text "Venue: #{volunteer.venue_name}", size: 10, style: :bold
        end

        pdf.move_down(10)
        pdf.text "Hi SYG volunteer!", size: 10
        pdf.move_down(10)
        pdf.text "Note: You may be receiving this as a Group Co-ordinator of the intended volunteer, if the volunteer does not have an email address recorded in the SYG Registrations system. If that is the case, please pass this email on to the actual volunteer.", size: 10, style: :italic

        pdf.move_down(10)
        unless volunteer.instructions.blank?
          pdf.text volunteer.instructions.to_plain_text, size: 10
        else
          unless volunteer.volunteer_type.instructions.blank?
            pdf.text volunteer.volunteer_type.instructions.to_plain_text, size: 10
          end
        end
      elsif volunteer.email_template_to_use == "Sport Coordinator"
        pdf.move_down(10)
        pdf.text "Email content is as per standard Sport Coordinator template", size: 10, style: :italic
      end
    end

    pdf.move_down(10)
    pdf.stroke_horizontal_rule
    pdf.move_down(10)
  end
end