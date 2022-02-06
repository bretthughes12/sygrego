# == Schema Information
#
# Table name: roles
#
#  id                  :integer          not null, primary key
#  name                :string(20)
#  group_related       :boolean          default("false")
#  participant_related :boolean          default("false")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#

FactoryBot.define do
  factory :role do
    sequence(:name)       { |n| "Role#{n}"}
    group_related         { false }
    participant_related   { false }

    trait :admin do
      name                { "admin" }
    end

    trait :church_rep do
      name                { "church_rep" }
      group_related       { true }
      end

    trait :gc do
      name                { "gc" }
      group_related       { true }
    end

    trait :participant do
      name                { "participant" }
      participant_related { true }
    end
  end
end
