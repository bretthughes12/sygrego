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