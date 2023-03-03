# == Schema Information
#
# Table name: event_details
#
#  id                  :bigint           not null, primary key
#  buddy_comments      :text
#  buddy_interest      :string(50)
#  camping_rqmts       :text
#  caravans            :integer          default(0)
#  estimated_numbers   :integer          default(0)
#  fire_pit            :boolean          default(TRUE)
#  marquee_co          :string(50)
#  marquee_sizes       :string(255)
#  marquees            :integer          default(0)
#  number_of_vehicles  :integer          default(0)
#  onsite              :boolean          default(TRUE)
#  orientation_details :string(100)
#  service_pref_sat    :string(20)       default("No preference")
#  service_pref_sun    :string(20)       default("No preference")
#  tents               :integer          default(0)
#  updated_by          :bigint
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :bigint
#  warden_zone_id      :bigint
#
# Indexes
#
#  index_event_details_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
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
