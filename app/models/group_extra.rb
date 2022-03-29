# == Schema Information
#
# Table name: group_extras
#
#  id             :bigint           not null, primary key
#  comment_prompt :string
#  cost           :decimal(8, 2)
#  name           :string(20)       not null
#  needs_size     :boolean          default(FALSE)
#  optional       :boolean          default(TRUE)
#  show_comment   :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_id       :bigint           not null
#
# Indexes
#
#  index_group_extras_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
class GroupExtra < ApplicationRecord
  belongs_to :group
  has_many :participant_extras, dependent: :destroy

  validates :name,       presence: true,
                         length: { maximum: 20 }
  validates :cost,       presence: true,
                         numericality: true
  validates :comment_prompt,
            allow_blank: true,
            length: { maximum: 255 }
end
