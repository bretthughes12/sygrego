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

# This model represents a Blacklist of Sport Grades that groups
# do not want their participants to see when they log into their
# custom MySYG sites

class GroupsGradesFilter < ApplicationRecord
  belongs_to :grade
  belongs_to :group

  validates :group_id, uniqueness: { scope: [:grade_id] }
end
