# == Schema Information
#
# Table name: sections_volunteers
#
#  section_id   :integer          not null
#  volunteer_id :integer          not null
#
# Indexes
#
#  index_sections_volunteers_on_section_id    (section_id)
#  index_sections_volunteers_on_volunteer_id  (volunteer_id)
#

require "test_helper"

class SectionsVolunteerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
