# == Schema Information
#
# Table name: mysyg_settings
#
#  id                         :bigint           not null, primary key
#  address_option             :string(10)       default("Show")
#  allergy_option             :string(10)       default("Show")
#  allow_offsite              :boolean          default(TRUE)
#  allow_part_time            :boolean          default(TRUE)
#  approve_option             :string           default("Normal")
#  collect_age_by             :string(20)       default("Age")
#  dietary_option             :string(10)       default("Show")
#  extra_fee_per_day          :decimal(8, 2)    default(0.0)
#  extra_fee_total            :decimal(8, 2)    default(0.0)
#  indiv_sport_view_strategy  :string           default("Show all")
#  medical_option             :string(10)       default("Show")
#  medicare_option            :string(10)       default("Show")
#  mysyg_code                 :string(25)
#  mysyg_enabled              :boolean          default(FALSE)
#  mysyg_name                 :string(50)
#  mysyg_open                 :boolean          default(FALSE)
#  participant_instructions   :text
#  require_emerg_contact      :boolean          default(FALSE)
#  require_medical            :boolean          default(FALSE)
#  show_finance_in_mysyg      :boolean          default(TRUE)
#  show_group_extras_in_mysyg :boolean          default(TRUE)
#  show_sports_in_mysyg       :boolean          default(TRUE)
#  show_sports_on_signup      :boolean          default(FALSE)
#  show_volunteers_in_mysyg   :boolean          default(TRUE)
#  team_sport_view_strategy   :string           default("Show all")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  group_id                   :bigint
#
# Indexes
#
#  index_mysyg_settings_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#

class MysygSetting < ApplicationRecord
    require 'roo'
  
    attr_reader :file
  
    belongs_to :group

    has_one_attached :policy
    has_rich_text :instructions
    has_rich_text :policy_text
    has_rich_text :email_text

    APPROVAL_OPTIONS = %w[Tolerant
        Normal
        Strict].freeze

    FIELD_OPTIONS = %w[Show
        Hide
        Require].freeze

    VIEW_STRATEGIES = ['Show all',
        'Show none',
        'Show sport entries only',
        'Show listed'].freeze

    AGE_OPTIONS = ['Age',
        'Date of Birth'].freeze

    validates :mysyg_code,      
        length: { maximum: 25 }
    validates :approve_option,      
        length: { maximum: 10 },
        inclusion: { in: APPROVAL_OPTIONS }
    validates :address_option,      
        length: { maximum: 10 },
        inclusion: { in: FIELD_OPTIONS }
    validates :allergy_option,      
        length: { maximum: 10 },
        inclusion: { in: FIELD_OPTIONS }
    validates :dietary_option,      
        length: { maximum: 10 },
        inclusion: { in: FIELD_OPTIONS }
    validates :medical_option,      
        length: { maximum: 10 },
        inclusion: { in: FIELD_OPTIONS }
    validates :medicare_option,      
        length: { maximum: 10 },
        inclusion: { in: FIELD_OPTIONS }
    validates :collect_age_by,      
        length: { maximum: 20 },
        inclusion: { in: AGE_OPTIONS }
    validates :team_sport_view_strategy, 
        length: { maximum: 25 },
        inclusion: { in: VIEW_STRATEGIES }
    validates :indiv_sport_view_strategy, 
        length: { maximum: 25 },
        inclusion: { in: VIEW_STRATEGIES }
    validates :extra_fee_total,
        presence: true,
        numericality: true
    validates :extra_fee_per_day,
        presence: true,
        numericality: true

    def update_name!(name)
        self.mysyg_name = name.downcase.gsub(/[\[\] ,\.\/\']/,'')
        self.save
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

                if group
                    mysyg_setting = group.mysyg_setting
                    if mysyg_setting
                        mysyg_setting.mysyg_name                 = group.short_name.downcase
                        mysyg_setting.mysyg_enabled              = row['Enabled']
                        mysyg_setting.mysyg_open                 = row['Open']
                        mysyg_setting.participant_instructions   = row['Instr']
                        mysyg_setting.extra_fee_total            = row['ExtraFee']
                        mysyg_setting.extra_fee_per_day          = row['ExtraFeePerDay']
                        mysyg_setting.show_sports_on_signup      = row['ShowSportsOnSignup']
                        mysyg_setting.show_sports_in_mysyg       = row['ShowSportsInMySYG']
                        mysyg_setting.show_volunteers_in_mysyg   = row['ShowVol']
                        mysyg_setting.show_finance_in_mysyg      = row['ShowFinance']  
                        mysyg_setting.show_group_extras_in_mysyg = row['ShowExtras']
                        mysyg_setting.allow_offsite              = row['AllowOffsite']
                        mysyg_setting.allow_part_time            = row['AllowPartTime']
                        mysyg_setting.collect_age_by             = row['AgeOption']
                        mysyg_setting.require_emerg_contact      = row['RequireEmerg']
                        mysyg_setting.address_option             = row['AddressOption']
                        mysyg_setting.allergy_option             = row['AllergyOption']
                        mysyg_setting.dietary_option             = row['DietaryOption']
                        mysyg_setting.medical_option            = row['MedicalOption']
                        mysyg_setting.medicare_option            = row['MedicareOption']
                        mysyg_setting.approve_option             = row['ApproveOption']
                        mysyg_setting.team_sport_view_strategy   = row['TeamView']
                        mysyg_setting.indiv_sport_view_strategy  = row['IndivView']
            
                        if mysyg_setting.save
                            updates += 1
                        else
                            errors += 1
                            error_list << mysyg_setting
                        end
                    end
                end
            end
        end
    
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end
end
