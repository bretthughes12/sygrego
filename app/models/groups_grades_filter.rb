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

# This model represents a Blacklist of Sport Grades that groups
# do not want their participants to see when they log into their
# custom MySYG sites

class GroupsGradesFilter < ApplicationRecord
  belongs_to :grade
  belongs_to :group

  validates :group_id, uniqueness: { scope: [:grade_id] }
end
