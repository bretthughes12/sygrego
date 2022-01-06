jQuery ->
  $('#grade_field').hide()
  grades = $('#sport_entry_grade_id').html()
  $('#sport_entry_sport_id').change ->
    sport = $('#sport_entry_sport_id :selected').text()
    options = $(grades).filter("optgroup[label='#{sport}']").html()
    if options
      $('#sport_entry_grade_id').html(options)
      $('#grade_field').show()
    else
      $('#sport_entry_grade_id').empty()
      $('#grade_field').hide()