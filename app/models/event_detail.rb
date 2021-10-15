# == Schema Information
#
# Table name: event_details
#
#  id                 :bigint           not null, primary key
#  buddy_comments     :text
#  buddy_interest     :string(50)
#  camping_rqmts      :text
#  caravans           :integer
#  estimated_numbers  :integer
#  fire_pit           :boolean
#  marquee_co         :string(50)
#  marquee_sizes      :string(255)
#  marquees           :integer
#  number_of_vehicles :integer
#  onsite             :boolean
#  service_pref_sat   :string(20)       default("No preference")
#  service_pref_sun   :string(20)       default("No preference")
#  tents              :integer
#  updated_by         :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  group_id           :bigint
#
# Indexes
#
#  index_event_details_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
class EventDetail < ApplicationRecord
    include Auditable

    require 'csv'
  
    attr_reader :file

    belongs_to :group

    has_one_attached :food_cert

    scope :coming, -> { where(coming: true) }
    scope :not_coming, -> { where(coming: false) }
    scope :onsite, -> { where(onsite: true) }
    scope :offsite, -> { where(onsite: false) }
    scope :buddy_interest, -> { where("not (buddy_interest = 'Not interested')") }
    scope :sat_early_service, -> { where(service_pref_sat: '7:00pm') }
    scope :sat_late_service, -> { where(service_pref_sat: '8:30pm') }
    scope :sat_no_pref_service, -> { where(service_pref_sat: 'No preference') }
    scope :sun_early_service, -> { where(service_pref_sun: '7:00pm') }
    scope :sun_late_service, -> { where(service_pref_sun: '8:30pm') }
    scope :sun_no_pref_service, -> { where(service_pref_sun: 'No preference') }
    
    SERVICE_PREFERENCES = ['7:00pm',
        '8:30pm',
        'No preference'].freeze

    BUDDY_INTEREST = ['Not interested',
       'Interested in adopting a group',
       'Interested in being adopted by a group',
       'Already adopting a group',
       'Already being adopted by a group'].freeze

    validates :marquee_co,          length: { maximum: 50 }
    validates :buddy_interest,      length: { maximum: 50 },
                                    inclusion: { in: BUDDY_INTEREST }
    validates :service_pref_sat,    length: { maximum: 20 },
                                    inclusion: { in: SERVICE_PREFERENCES }
    validates :service_pref_sun,    length: { maximum: 20 },
                                    inclusion: { in: SERVICE_PREFERENCES }
    validates :tents,               numericality: true,
                                    allow_blank: true
    validates :caravans,            numericality: true,
                                    allow_blank: true
    validates :marquees,            numericality: true,
                                    allow_blank: true
    validates :estimated_numbers,   presence: true,
                                    numericality: { only_integer: true }
    validates :number_of_vehicles,  presence: true,
                                    numericality: { only_integer: true }

private

    def self.sync_fields
        ['onsite'
        ]
    end
end
