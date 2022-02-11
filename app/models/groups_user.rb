# == Schema Information
#
# Table name: groups_users
#
#  group_id :bigint
#  user_id  :bigint
#
# Indexes
#
#  index_groups_users_on_group_id  (group_id)
#  index_groups_users_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (user_id => users.id)
#

class GroupsUser < ApplicationRecord
end
