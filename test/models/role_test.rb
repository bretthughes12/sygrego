# == Schema Information
#
# Table name: roles
#
#  id                  :bigint           not null, primary key
#  group_related       :boolean          default(FALSE)
#  name                :string(20)
#  participant_related :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#

require "test_helper"

class RoleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
