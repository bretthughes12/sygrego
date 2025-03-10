# == Schema Information
#
# Table name: groups_sports_filters
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint           not null
#  sport_id   :bigint           not null
#
# Indexes
#
#  index_groups_sports_filters_on_group_id  (group_id)
#  index_groups_sports_filters_on_sport_id  (sport_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (sport_id => sports.id)
#

# This model represents a Blacklist of Sports that groups
# do not want their participants to see when they log into their
# custom MySYG sites

class GroupsSportsFilter < ApplicationRecord
  belongs_to :sport
  belongs_to :group

  validates :group_id, uniqueness: { scope: [:sport_id] }
end
