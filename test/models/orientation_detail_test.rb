# == Schema Information
#
# Table name: orientation_details
#
#  id              :integer          not null, primary key
#  name            :string(20)
#  venue_name      :string
#  venue_address   :string
#  event_date_time :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require "test_helper"

class OrientationDetailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
