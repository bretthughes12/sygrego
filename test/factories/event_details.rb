# == Schema Information
#
# Table name: event_details
#
#  id                 :integer          not null, primary key
#  onsite             :boolean          default("true")
#  fire_pit           :boolean          default("true")
#  camping_rqmts      :text
#  tents              :integer          default("0")
#  caravans           :integer          default("0")
#  marquees           :integer          default("0")
#  marquee_sizes      :string(255)
#  marquee_co         :string(50)
#  buddy_interest     :string(50)
#  buddy_comments     :text
#  service_pref_sat   :string(20)       default("No preference")
#  service_pref_sun   :string(20)       default("No preference")
#  estimated_numbers  :integer          default("0")
#  number_of_vehicles :integer          default("0")
#  updated_by         :integer
#  group_id           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_event_details_on_group_id  (group_id)
#

FactoryBot.define do
  factory :event_detail do
    group

    onsite { true }
    fire_pit { true }
    camping_rqmts { "Same campsite as last year" }
    tents { 6 }
    caravans { 2 }
    marquees { 1 }
    marquee_sizes { "20mx10m" }
    marquee_co { "Acme Marquee Co" }
    buddy_interest { "Not interested" }
    buddy_comments { "" }
    service_pref_sat { "No preference" }
    service_pref_sun { "No preference" }
    estimated_numbers { 10 }
    number_of_vehicles { 4 }
  end
end
