# == Schema Information
#
# Table name: rego_checklists
#
#  id                    :bigint           not null, primary key
#  admin_rep             :string(40)
#  covid_plan_sighted    :boolean          default(FALSE)
#  disabled_notes        :text
#  disabled_participants :boolean          default(FALSE)
#  driver_form           :boolean          default(FALSE)
#  driving_notes         :text
#  finance_notes         :text
#  food_cert_sighted     :boolean          default(FALSE)
#  insurance_sighted     :boolean          default(FALSE)
#  registered            :boolean          default(FALSE)
#  rego_mobile           :string(30)
#  rego_rep              :string(40)
#  second_mobile         :string(30)
#  second_rep            :string(40)
#  sport_notes           :text
#  upload_notes          :text
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

  trait :blank do
    rego_rep    { "" }
    rego_mobile { "" }
    admin_rep   { "" }
  end
end
