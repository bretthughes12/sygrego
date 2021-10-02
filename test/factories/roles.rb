# == Schema Information
#
# Table name: roles
#
#  id         :bigint           not null, primary key
#  name       :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer
#
FactoryBot.define do
  factory :role do
    name { "MyString" }
    group_id { 1 }
  end
end
