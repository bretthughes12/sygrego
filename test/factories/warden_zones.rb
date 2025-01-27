# == Schema Information
#
# Table name: warden_zones
#
#  id          :integer          not null, primary key
#  zone        :integer
#  warden_info :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :warden_zone do
    zone { 1 }
    warden_info { "MyText" }
  end
end
