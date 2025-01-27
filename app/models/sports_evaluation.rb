# == Schema Information
#
# Table name: sports_evaluations
#
#  id               :integer          not null, primary key
#  sport            :string(20)       not null
#  section          :string(50)       not null
#  session          :string(50)       not null
#  venue_rating     :string(10)       not null
#  equipment_rating :string           not null
#  length_rating    :string           not null
#  umpiring_rating  :string           not null
#  results_rating   :string           not null
#  time_rating      :string           not null
#  support_rating   :string           not null
#  safety_rating    :string           not null
#  scoring_rating   :string           not null
#  worked_well      :text
#  to_improve       :text
#  suggestions      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_sports_evaluations_on_section  (section)
#

class SportsEvaluation < ApplicationRecord
    RATING = ['NA',
        'Bad',
        'Average',
        'Good',
        'Excellent'
    ].freeze

    validates :sport,
        presence: true,
        length: { maximum: 20 }
    validates :section,
        presence: true,
        length: { maximum: 50 }
    validates :session,
        presence: true,
        length: { maximum: 50 }
    validates :venue_rating,
        presence: true,
        length: { maximum: 10 },
        inclusion: { in: RATING }
    validates :equipment_rating,
        presence: true,
        length: { maximum: 10 },
        inclusion: { in: RATING }
    validates :length_rating,
        presence: true,
        length: { maximum: 10 },
        inclusion: { in: RATING }
    validates :umpiring_rating,
        presence: true,
        length: { maximum: 10 },
        inclusion: { in: RATING }
    validates :scoring_rating,
        presence: true,
        length: { maximum: 10 },
        inclusion: { in: RATING }
    validates :time_rating,
        presence: true,
        length: { maximum: 10 },
        inclusion: { in: RATING }
    validates :support_rating,
        presence: true,
        length: { maximum: 10 },
        inclusion: { in: RATING }
    validates :safety_rating,
        presence: true,
        length: { maximum: 10 },
        inclusion: { in: RATING }
    validates :results_rating,
        presence: true,
        length: { maximum: 10 },
        inclusion: { in: RATING }
end
