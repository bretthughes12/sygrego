# == Schema Information
#
# Table name: timelines
#
#  id          :integer          not null, primary key
#  key_date    :date             not null
#  name        :string(50)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_timelines_on_key_date_and_name  (key_date,name)
#

class Timeline < ApplicationRecord
    scope :current, -> { where(['key_date >= ?', Date.today.in_time_zone]) }

    validates :key_date,               presence: true
    validates :name,                   length: { maximum: 50 }
    validates :description,            length: { maximum: 255 }
end
