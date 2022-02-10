# == Schema Information
#
# Table name: volunteer_types
#
#  id            :integer          not null, primary key
#  name          :string(100)      not null
#  sport_related :boolean          default("false")
#  t_shirt       :boolean          default("false")
#  description   :text
#  database_code :string(4)
#  active        :boolean          default("true")
#  updated_by    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
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
    active { true }
  end
end
