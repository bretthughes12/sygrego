# == Schema Information
#
# Table name: volunteer_types
#
#  id                   :bigint           not null, primary key
#  active               :boolean          default(TRUE)
#  age_category         :string(20)       default("Over 18")
#  cc_email             :string(100)
#  database_code        :string(4)
#  description          :text
#  email_template       :string(20)       default("Default")
#  name                 :string(100)      not null
#  send_volunteer_email :boolean          default(FALSE)
#  sport_related        :boolean          default(FALSE)
#  t_shirt              :boolean          default(FALSE)
#  updated_by           :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_volunteer_types_on_name  (name) UNIQUE
#

class VolunteerType < ApplicationRecord
    include Comparable
    include Auditable

    has_many :volunteers

    has_rich_text :instructions
    has_rich_text :signature

    scope :sport_related, -> { where(sport_related: true) }
    scope :non_sport_related, -> { where(sport_related: false) }
    scope :active, -> { where(active: true) }
    scope :to_be_emailed, -> { where(send_volunteer_email: true) }

    AGE_CATEGORIES = ['Over 18',
                      'Over 16'].freeze
    EMAIL_TEMPLATES = ['Default',
                       'Override',
                       'Sport Coordinator'].freeze

    validates :name, presence: true, uniqueness: true,
        length: { maximum: 100 }
    validates :database_code, uniqueness: true,
        length: { maximum: 4 }
    validates :age_category,           
        length: { maximum: 20 },
        inclusion: { in: AGE_CATEGORIES }
    validates :cc_email, 
        length: { maximum: 100 }
    validates :email_template,           
        length: { maximum: 20 },
        inclusion: { in: EMAIL_TEMPLATES }
        
    def min_age
        if age_category == 'Over 16'
            16
        else
            18
        end
    end
    
    def self.import_excel(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
    
        xlsx = Roo::Spreadsheet.open(file)

        xlsx.sheet(xlsx.default_sheet).parse(headers: true).each do |row|
            unless row['RowID'] == 'RowID'

                type = VolunteerType.find_by_name(row['Name'].to_s)
                if type
                    type.active = row['Active']
                    type.database_code = row['RowID']
                    type.sport_related = row['SportRelated']
                    type.t_shirt = row['T-Shirt']
                    type.description = row['Description']
                    type.age_category = row['AgeCategory']
                    type.send_volunteer_email = row['SendEmail']
                    type.cc_email = row['CC']
                    type.email_template = row['Template']
                    type.updated_by = user.id
                    if type.save
                        updates += 1
                    else
                        errors += 1
                        error_list << type
                    end
                else
                    type = VolunteerType.create(
                        name:                      row['Name'],
                        active:                    row['Active'],
                        database_code:             row['RowID'],
                        sport_related:             row['SportRelated'],
                        t_shirt:                   row['T-Shirt'],
                        description:               row['Description'],
                        age_category:              row['AgeCategory'],
                        send_volunteer_email:      row['SendEmail'],
                        cc_email:                  row['CC'],
                        email_template:            row['Template'],
                        updated_by:                user.id)
                    if type.errors.empty?
                        creates += 1
                    else
                        errors += 1
                        error_list << type
                    end
                end
            end
        end
    
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end
    
    private

    def self.sync_fields
        ['name',
         'database_code',
         'sport_related',
         'active']
    end
end
