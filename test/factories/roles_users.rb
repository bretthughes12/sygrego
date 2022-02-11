# == Schema Information
#
# Table name: roles_users
#
#  role_id :bigint
#  user_id :bigint
#
# Indexes
#
#  index_roles_users_on_role_id  (role_id)
#  index_roles_users_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :roles_user do
    role_id { 1 }
    user_id { 1 }
  end
end
