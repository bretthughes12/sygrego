# == Schema Information
#
# Table name: event_details
#
#  id                 :bigint           not null, primary key
#  buddy_comments     :text
#  buddy_interest     :string(50)
#  camping_rqmts      :text
#  caravans           :integer          default(0)
#  estimated_numbers  :integer          default(0)
#  fire_pit           :boolean          default(TRUE)
#  marquee_co         :string(50)
#  marquee_sizes      :string(255)
#  marquees           :integer          default(0)
#  number_of_vehicles :integer          default(0)
#  onsite             :boolean          default(TRUE)
#  service_pref_sat   :string(20)       default("No preference")
#  service_pref_sun   :string(20)       default("No preference")
#  tents              :integer          default(0)
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

    def self.import(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
    
        CSV.foreach(file.path, headers: true) do |fields|
            group = Group.find_by_abbr(fields[1].to_s)

            if group
                event_detail = group.event_detail
                if event_detail
                    event_detail.onsite             = fields[2]
                    event_detail.fire_pit           = fields[3]
                    event_detail.camping_rqmts      = fields[4]
                    event_detail.tents              = fields[5].to_i
                    event_detail.caravans           = fields[6].to_i
                    event_detail.marquees           = fields[7].to_i
                    event_detail.marquee_sizes      = fields[8]
                    event_detail.marquee_co         = fields[9]  
                    event_detail.buddy_interest     = fields[10]
                    event_detail.buddy_comments     = fields[11]
                    event_detail.service_pref_sat   = fields[12]
                    event_detail.service_pref_sun   = fields[13]
                    event_detail.estimated_numbers  = fields[14].to_i
                    event_detail.number_of_vehicles = fields[15].to_i
                    event_detail.updated_by = user.id
        
                    if event_detail.save
                        updates += 1
                    else
                        errors += 1
                        error_list << event_detail
                    end
                else
                    event_detail = EventDetail.create(
                        group_id:            group.id,
                        onsite:              fields[2],
                        fire_pit:            fields[3],
                        camping_rqmts:       fields[4],
                        tents:               fields[5].to_i,
                        caravans:            fields[6].to_i,
                        marquees:            fields[7].to_i,
                        marquee_sizes:       fields[8],
                        marquee_co:          fields[9],
                        buddy_interest:      fields[10],
                        buddy_comments:      fields[11],
                        service_pref_sat:    fields[12],
                        service_pref_sun:    fields[13],
                        estimated_numbers:   fields[14].to_i,
                        number_of_vehicles:  fields[15].to_i,
                        updated_by:          user.id)

                    if event_detail.errors.empty?
                        creates += 1
                    else
                        errors += 1
                        error_list << event_detail
                    end
                end
            end
        end
    
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end

    private

    def self.sync_fields
        ['onsite'
        ]
    end
end
