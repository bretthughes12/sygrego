# == Schema Information
#
# Table name: groups_grades_filters
#
#  id         :integer          not null, primary key
#  grade_id   :integer          not null
#  group_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_groups_grades_filters_on_grade_id  (grade_id)
#  index_groups_grades_filters_on_group_id  (group_id)
#

FactoryBot.define do
  factory :groups_grades_filter do
    grade { nil }
    group { nil }
  end
end
