# == Schema Information
#
# Table name: event_details
#
#  id                        :bigint           not null, primary key
#  buddy_comments            :text
#  buddy_interest            :string(50)
#  camping_rqmts             :text
#  caravans                  :integer          default(0)
#  estimated_numbers         :integer          default(0)
#  fire_pit                  :boolean          default(TRUE)
#  marquee_co                :string(50)
#  marquee_sizes             :string(255)
#  marquees                  :integer          default(0)
#  number_of_vehicles        :integer          default(0)
#  onsite                    :boolean          default(TRUE)
#  orientation_details       :string(100)
#  policy_child_safe_checked :boolean          default(FALSE)
#  policy_code_checked       :boolean          default(FALSE)
#  policy_code_u18_checked   :boolean          default(FALSE)
#  policy_day_vis_checked    :boolean          default(FALSE)
#  policy_driving_checked    :boolean          default(FALSE)
#  policy_drone_checked      :boolean          default(FALSE)
#  policy_image_use_checked  :boolean          default(FALSE)
#  policy_medicine_checked   :boolean          default(FALSE)
#  policy_refund_checked     :boolean          default(FALSE)
#  policy_shower_checked     :boolean          default(FALSE)
#  policy_website_checked    :boolean          default(FALSE)
#  policy_wwcc_checked       :boolean          default(FALSE)
#  service_pref_fri          :string(20)       default("No preference")
#  service_pref_sat          :string(20)       default("No preference")
#  service_pref_sun          :string(20)       default("No preference")
#  tents                     :integer          default(0)
#  updated_by                :bigint
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  group_id                  :bigint
#  orientation_detail_id     :bigint
#  warden_zone_id            :bigint
#
# Indexes
#
#  index_event_details_on_group_id               (group_id)
#  index_event_details_on_orientation_detail_id  (orientation_detail_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (orientation_detail_id => orientation_details.id)
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
