# == Schema Information
#
# Table name: venues
#
#  id            :integer          not null, primary key
#  name          :string(50)       default(""), not null
#  database_code :string(4)
#  address       :string
#  updated_by    :integer
#  active        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_venues_on_database_code  (database_code) UNIQUE
#  index_venues_on_name           (name) UNIQUE
#

FactoryBot.define do
  factory :venue do
    sequence(:name)             { |n| "Venue#{n}"}
    sequence(:database_code)    { |n| "V#{n}"}
  end
end
