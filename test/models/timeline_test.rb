# == Schema Information
#
# Table name: timelines
#
#  id          :integer          not null, primary key
#  key_date    :date             not null
#  name        :string(50)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_timelines_on_key_date_and_name  (key_date,name)
#

require "test_helper"

class TimelineTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
