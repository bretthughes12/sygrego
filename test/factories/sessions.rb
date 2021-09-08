# == Schema Information
#
# Table name: sessions
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  name       :string           not null
#  updated_by :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :session do
    sequence(:name)             { |n| "Session#{n}"}
  end
end
