# == Schema Information
#
# Table name: group_fee_categories
#
#  id              :bigint           not null, primary key
#  adjustment_type :string(15)       default("Add")
#  amount          :decimal(8, 2)    default(1.0)
#  description     :string(40)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  group_id        :bigint           not null
#
# Indexes
#
#  index_group_fee_categories_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
require "test_helper"

class GroupFeeCategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
