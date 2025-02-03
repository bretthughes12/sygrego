# == Schema Information
#
# Table name: orientation_details
#
#  id              :integer          not null, primary key
#  name            :string(20)
#  venue_name      :string
#  venue_address   :string
#  event_date_time :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class OrientationDetail < ApplicationRecord
  has_many :event_details

  validates :name,                  presence: true,
                                    length: { maximum: 20 }

  def description
    "#{name} - #{venue_name} - #{event_date_time.strftime("%d/%m/%Y %I:%M %p")}"
  end
end
