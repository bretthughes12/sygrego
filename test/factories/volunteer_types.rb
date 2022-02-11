# == Schema Information
#
# Table name: volunteer_types
#
#  id            :bigint           not null, primary key
#  active        :boolean          default(TRUE)
#  database_code :string(4)
#  description   :text
#  name          :string(100)      not null
#  sport_related :boolean          default(FALSE)
#  t_shirt       :boolean          default(FALSE)
#  updated_by    :bigint
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
