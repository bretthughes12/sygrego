# == Schema Information
#
# Table name: warden_zones
#
#  id          :integer          not null, primary key
#  zone        :integer
#  warden_info :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "test_helper"

class WardenZoneTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
