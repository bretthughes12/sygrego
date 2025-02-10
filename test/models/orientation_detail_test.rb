# == Schema Information
#
# Table name: orientation_details
#
#  id              :bigint           not null, primary key
#  event_date_time :datetime
#  name            :string(20)
#  venue_address   :string
#  venue_name      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require "test_helper"

class OrientationDetailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
