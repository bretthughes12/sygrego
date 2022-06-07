# == Schema Information
#
# Table name: warden_zones
#
#  id          :bigint           not null, primary key
#  warden_info :text
#  zone        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class WardenZoneTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
