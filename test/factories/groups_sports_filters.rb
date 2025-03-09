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
FactoryBot.define do
  factory :groups_sports_filter do
    sport_id { nil }
    group_id { nil }
  end
end
