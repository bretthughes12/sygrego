# == Schema Information
#
# Table name: venues
#
#  id            :bigint           not null, primary key
#  address       :string
#  database_code :string(4)
#  name          :string(50)       default(""), not null
#  updated_by    :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :venue do
    sequence(:name)             { |n| "Venue#{n}"}
    sequence(:database_code)    { |n| "V#{n}"}
  end
end
