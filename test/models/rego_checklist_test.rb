# == Schema Information
#
# Table name: rego_checklists
#
#  id                    :integer          not null, primary key
#  registered            :boolean          default("false")
#  rego_rep              :string(40)
#  rego_mobile           :string(30)
#  admin_rep             :string(40)
#  second_rep            :string(40)
#  second_mobile         :string(30)
#  disabled_participants :boolean          default("false")
#  disabled_notes        :text
#  driver_form           :boolean          default("false")
#  finance_notes         :text
#  sport_notes           :text
#  group_id              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_rego_checklists_on_group_id  (group_id)
#

require "test_helper"

class RegoChecklistTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
