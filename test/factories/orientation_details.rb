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

FactoryBot.define do
  factory :orientation_detail do
    name { "MyString" }
    venue_name { "MyString" }
    venue_address { "MyString" }
    event_date_time { "2025-02-01 19:51:29" }
  end
end
