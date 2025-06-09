# == Schema Information
#
# Table name: rego_checklists
#
#  id                        :bigint           not null, primary key
#  admin_rep                 :string(40)
#  covid_plan_sighted        :boolean          default(FALSE)
#  disabled_notes            :text
#  disabled_participants     :boolean          default(FALSE)
#  driver_form               :boolean          default(FALSE)
#  driving_notes             :text
#  finance_notes             :text
#  food_cert_sighted         :boolean          default(FALSE)
#  insurance_sighted         :boolean          default(FALSE)
#  registered                :boolean          default(FALSE)
#  rego_mobile               :string(30)
#  rego_rep                  :string(40)
#  second_mobile             :string(30)
#  second_rep                :string(40)
#  site_check_church_contact :string
#  site_check_completed_at   :datetime
#  site_check_completed_by   :string
#  site_check_electrical_1   :boolean          default(FALSE)
#  site_check_electrical_2   :boolean          default(FALSE)
#  site_check_electrical_3   :boolean          default(FALSE)
#  site_check_electrical_4   :boolean          default(FALSE)
#  site_check_electrical_5   :boolean          default(FALSE)
#  site_check_electrical_6   :boolean          default(FALSE)
#  site_check_electrical_7   :boolean          default(FALSE)
#  site_check_electrical_8   :boolean          default(FALSE)
#  site_check_fire_1         :boolean          default(FALSE)
#  site_check_fire_2         :boolean          default(FALSE)
#  site_check_fire_3         :boolean          default(FALSE)
#  site_check_fire_4         :boolean          default(FALSE)
#  site_check_flames_1       :boolean          default(FALSE)
#  site_check_flames_2       :boolean          default(FALSE)
#  site_check_flames_3       :boolean          default(FALSE)
#  site_check_flames_4       :boolean          default(FALSE)
#  site_check_flames_5       :boolean          default(FALSE)
#  site_check_flames_6       :boolean          default(FALSE)
#  site_check_flames_7       :boolean
#  site_check_food_1         :boolean          default(FALSE)
#  site_check_food_2         :boolean          default(FALSE)
#  site_check_food_3         :boolean          default(FALSE)
#  site_check_food_4         :boolean
#  site_check_gas_1          :boolean          default(FALSE)
#  site_check_gas_2          :boolean          default(FALSE)
#  site_check_medical_1      :boolean          default(FALSE)
#  site_check_medical_2      :boolean          default(FALSE)
#  site_check_medical_3      :boolean          default(FALSE)
#  site_check_medical_4      :boolean          default(FALSE)
#  site_check_medical_5      :boolean          default(FALSE)
#  site_check_medical_6      :boolean          default(FALSE)
#  site_check_medical_7      :boolean
#  site_check_notes          :string
#  site_check_onsite_notes   :text
#  site_check_safety_1       :boolean          default(FALSE)
#  site_check_safety_2       :boolean          default(FALSE)
#  site_check_safety_3       :boolean          default(FALSE)
#  site_check_safety_4       :boolean          default(FALSE)
#  site_check_safety_5       :boolean          default(FALSE)
#  site_check_safety_6       :boolean
#  site_check_site_1         :boolean          default(FALSE)
#  site_check_site_2         :boolean          default(FALSE)
#  site_check_status         :string(20)       default("Not completed")
#  sport_notes               :text
#  upload_notes              :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  group_id                  :bigint
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
