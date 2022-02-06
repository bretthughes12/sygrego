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

FactoryBot.define do
  factory :rego_checklist do
    group 
    
    registered { false }
    rego_rep { "MyString" }
    rego_mobile { "MyString" }
    admin_rep { "MyString" }
    second_rep { "MyString" }
    second_mobile { "MyString" }
    disabled_participants { false }
    disabled_notes { "MyText" }
    driver_form { false }
    finance_notes { "MyText" }
    sport_notes { "MyText" }
  end
end
