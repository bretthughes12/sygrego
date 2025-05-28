# == Schema Information
#
# Table name: volunteer_types
#
#  id                   :bigint           not null, primary key
#  active               :boolean          default(TRUE)
#  age_category         :string(20)       default("Over 18")
#  cc_email             :string(100)
#  database_code        :string(4)
#  description          :text
#  email_template       :string(20)       default("Default")
#  name                 :string(100)      not null
#  send_volunteer_email :boolean          default(FALSE)
#  sport_related        :boolean          default(FALSE)
#  t_shirt              :boolean          default(FALSE)
#  updated_by           :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_volunteer_types_on_name  (name) UNIQUE
#

FactoryBot.define do
  factory :volunteer_type do
    sequence(:database_code)    { |n| "V#{n}"}
    sequence(:name)             { |n| "VType#{n}"}
    sport_related { false }
    t_shirt { false }
    description { "Ipsup Lorem..." }
    age_category { "Over 18" }
    active { true }
  end

  trait :over_18 do
    age_category { "Over 18" }
  end

  trait :over_16 do
    age_category { "Over 16" }
  end

  trait :sport_coord do
    name         { "Sport Coordinator" }
  end
end
