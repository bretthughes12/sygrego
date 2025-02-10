# == Schema Information
#
# Table name: sections_volunteers
#
#  section_id   :bigint           not null
#  volunteer_id :bigint           not null
#
# Indexes
#
#  index_sections_volunteers_on_section_id    (section_id)
#  index_sections_volunteers_on_volunteer_id  (volunteer_id)
#
# Foreign Keys
#
#  fk_rails_...  (section_id => sections.id)
#  fk_rails_...  (volunteer_id => volunteers.id)
#

require "test_helper"

class SectionsVolunteerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
