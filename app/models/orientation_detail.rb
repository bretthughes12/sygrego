# == Schema Information
#
# Table name: orientation_details
#
#  id              :bigint           not null, primary key
#  event_date_time :datetime
#  name            :string(20)
#  venue_address   :string
#  venue_name      :string
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
