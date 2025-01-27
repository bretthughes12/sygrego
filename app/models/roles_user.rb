# == Schema Information
#
# Table name: roles_users
#
#  role_id :integer
#  user_id :integer
#
# Indexes
#
#  index_roles_users_on_role_id  (role_id)
#  index_roles_users_on_user_id  (user_id)
#

class RolesUser < ApplicationRecord
end
