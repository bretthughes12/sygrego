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

class EventDetail < ApplicationRecord
    include Auditable

    require 'csv'
  
    attr_reader :file

    belongs_to :group
    belongs_to :warden_zone, optional: true

    has_one_attached :food_cert
    has_one_attached :covid_plan
    has_one_attached :insurance

    scope :onsite, -> { where(onsite: true) }
    scope :offsite, -> { where(onsite: false) }
    scope :buddy_interest, -> { where("not (buddy_interest = 'Not interested')") }
    
    SERVICE_PREFERENCES = ['7:00pm',
        '8:45pm',
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
    validates :orientation_details, length: { maximum: 100 }

    def self.sat_early_service
        groups = []
        EventDetail.all.each do |ed|
            groups << ed.group if ed.group.coming && !ed.group.admin_use && ed.service_pref_sat == '7:00pm'
        end
        groups
    end

    def self.sat_late_service
        groups = []
        EventDetail.all.each do |ed|
            groups << ed.group if ed.group.coming && !ed.group.admin_use && ed.service_pref_sat == '8:45pm'
        end
        groups
    end

    def self.sat_no_pref_service
        groups = []
        EventDetail.all.each do |ed|
            groups << ed.group if ed.group.coming && !ed.group.admin_use && ed.service_pref_sat == 'No preference'
        end
        groups
    end

    def self.sun_early_service
        groups = []
        EventDetail.all.each do |ed|
            groups << ed.group if ed.group.coming && !ed.group.admin_use && ed.service_pref_sun == '7:00pm'
        end
        groups
    end

    def self.sun_late_service
        groups = []
        EventDetail.all.each do |ed|
            groups << ed.group if ed.group.coming && !ed.group.admin_use && ed.service_pref_sun == '8:45pm'
        end
        groups
    end

    def self.sun_no_pref_service
        groups = []
        EventDetail.all.each do |ed|
            groups << ed.group if ed.group.coming && !ed.group.admin_use && ed.service_pref_sun == 'No preference'
        end
        groups
    end

    def warden_zone_name
        warden_zone.nil? ? '' : warden_zone.name
    end
    
    def warden_info
        warden_zone.nil? ? '' : warden_zone.warden_info
    end
    
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
                end
            end
        end
    
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end

    def self.import_excel(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
    
        xlsx = Roo::Spreadsheet.open(file)

        xlsx.sheet(xlsx.default_sheet).parse(headers: true).each do |row|
            unless row['RowID'] == 'RowID'
                group = Group.find_by_abbr(row['Abbr'].to_s)
                if row['WardenZone'].blank?
                    zone = nil
                else
                    zone = WardenZone.find_by_zone(row['WardenZone'].to_i)
                end

                if group
                    event_detail = group.event_detail
                    if event_detail
                        event_detail.orientation_details = row['Orientation']
                        event_detail.warden_zone         = zone
                        event_detail.onsite              = row['Onsite']
                        event_detail.fire_pit            = row['FirePit']
                        event_detail.camping_rqmts       = row['CampingRqmts']
                        event_detail.tents               = row['Tents'].to_i
                        event_detail.caravans            = row['Caravans'].to_i
                        event_detail.marquees            = row['Marquees'].to_i
                        event_detail.marquee_sizes       = row['MarqueeSizes']
                        event_detail.marquee_co          = row['MarqueeCo']  
                        event_detail.buddy_interest      = row['BuddyInterest']
                        event_detail.buddy_comments      = row['BuddyComments']
                        event_detail.service_pref_sat    = row['ServiceSat']
                        event_detail.service_pref_sun    = row['ServiceSun']
                        event_detail.estimated_numbers   = row['EstNumbers'].to_i
                        event_detail.number_of_vehicles  = row['Vehicles'].to_i
                        event_detail.updated_by = user.id
            
                        if event_detail.save
                            updates += 1
                        else
                            errors += 1
                            error_list << event_detail
                        end
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

    def self.sync_create_action
        'UPDATE'
    end
end
