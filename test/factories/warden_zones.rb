# == Schema Information
#
# Table name: warden_zones
#
#  id          :bigint           not null, primary key
#  warden_info :text
#  zone        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :warden_zone do
    zone { 1 }
    warden_info { "MyText" }
  end
end
