# == Schema Information
#
# Table name: groups_grades_filters
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  grade_id   :bigint           not null
#  group_id   :bigint           not null
#
# Indexes
#
#  index_groups_grades_filters_on_grade_id  (grade_id)
#  index_groups_grades_filters_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (group_id => groups.id)
#
FactoryBot.define do
  factory :groups_grades_filter do
    grade { nil }
    group { nil }
  end
end
