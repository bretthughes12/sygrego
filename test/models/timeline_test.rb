# == Schema Information
#
# Table name: timelines
#
#  id          :bigint           not null, primary key
#  description :string(255)
#  key_date    :date             not null
#  name        :string(50)
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
