# == Schema Information
#
# Table name: timelines
#
#  id          :bigint           not null, primary key
#  description :string(255)
#  key_date    :date             not null
#  name        :string(20)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_timelines_on_key_date_and_name  (key_date,name)
#

class Timeline < ApplicationRecord
    validates :key_date,               presence: true
    validates :name,                   length: { maximum: 20 }
    validates :description,            length: { maximum: 255 }
end
