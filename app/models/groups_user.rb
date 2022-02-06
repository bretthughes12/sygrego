# == Schema Information
#
# Table name: groups_users
#
#  group_id :integer
#  user_id  :integer
#
# Indexes
#
#  index_groups_users_on_group_id  (group_id)
#  index_groups_users_on_user_id   (user_id)
#

class GroupsUser < ApplicationRecord
end
