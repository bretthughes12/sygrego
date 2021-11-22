# == Schema Information
#
# Table name: rego_checklists
#
#  id                    :bigint           not null, primary key
#  admin_rep             :string(40)
#  disabled_notes        :text
#  disabled_participants :boolean          default(FALSE)
#  driver_form           :boolean          default(FALSE)
#  finance_notes         :text
#  registered            :boolean          default(FALSE)
#  rego_mobile           :string(30)
#  rego_rep              :string(40)
#  second_mobile         :string(30)
#  second_rep            :string(40)
#  sport_notes           :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  group_id              :bigint
#
# Indexes
#
#  index_rego_checklists_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
require "test_helper"

class RegoChecklistTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
