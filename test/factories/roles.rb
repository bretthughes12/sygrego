# == Schema Information
#
# Table name: roles
#
#  id                  :bigint           not null, primary key
#  group_related       :boolean          default(FALSE)
#  name                :string(20)
#  participant_related :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
FactoryBot.define do
  factory :role do
    sequence(:name)             { |n| "Role#{n}"}
    group_related { false }
    participant_related { false }
  end
end
