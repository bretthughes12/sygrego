# == Schema Information
#
# Table name: roles_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  role_id    :integer
#  user_id    :integer
#
require "test_helper"

class RolesUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
