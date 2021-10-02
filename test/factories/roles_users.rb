# == Schema Information
#
# Table name: roles_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  role_id    :integer
#  user_id    :integer
#
FactoryBot.define do
  factory :roles_user do
    role_id { 1 }
    user_id { 1 }
  end
end
