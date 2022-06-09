# == Schema Information
#
# Table name: awards
#
#  id              :bigint           not null, primary key
#  category        :string(20)       not null
#  description     :text             not null
#  flagged         :boolean          default(FALSE)
#  name            :string(100)      not null
#  submitted_by    :string(100)      not null
#  submitted_group :string(100)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_awards_on_name  (name)
#
class Award < ApplicationRecord
    scope :good_sports, -> { where(category: 'Good Sports') }
    scope :spirit, -> { where(category: 'Spirit') }
    scope :volunteer, -> { where(category: 'Volunteer') }

    CATEGORY = ['Good Sports',
        'Spirit',
        'Volunteer'
    ].freeze

    validates :category,
        presence: true,
        length: { maximum: 20 },
        inclusion: { in: CATEGORY }
    validates :name,
        presence: true,
        length: { maximum: 100 }
    validates :submitted_by,
        presence: true,
        length: { maximum: 100 }
    validates :submitted_group,
        presence: true,
        length: { maximum: 100 }
    validates :description,
        presence: true
end
