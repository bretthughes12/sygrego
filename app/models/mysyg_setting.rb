# == Schema Information
#
# Table name: mysyg_settings
#
#  id                         :bigint           not null, primary key
#  approve_option             :string           default("Normal")
#  extra_fee_per_day          :decimal(8, 2)    default(0.0)
#  extra_fee_total            :decimal(8, 2)    default(0.0)
#  indiv_sport_view_strategy  :string           default("Show all")
#  mysyg_code                 :string(25)
#  mysyg_enabled              :boolean          default(FALSE)
#  mysyg_name                 :string(50)
#  mysyg_open                 :boolean          default(FALSE)
#  participant_instructions   :text
#  show_finance_in_mysyg      :boolean          default(TRUE)
#  show_group_extras_in_mysyg :boolean          default(TRUE)
#  show_sports_in_mysyg       :boolean          default(TRUE)
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
    require 'csv'
  
    attr_reader :file
  
    belongs_to :group

    APPROVAL_OPTIONS = %w[Tolerant
        Normal
        Strict].freeze

    VIEW_STRATEGIES = ['Show all',
        'Show none',
        'Show sport entries only',
        'Show listed'].freeze

    validates :mysyg_code,      
        length: { maximum: 25 }
    validates :approve_option,      
        length: { maximum: 10 },
        inclusion: { in: APPROVAL_OPTIONS }
    validates :team_sport_view_strategy, 
        length: { maximum: 25 },
        inclusion: { in: VIEW_STRATEGIES }
    validates :indiv_sport_view_strategy, 
        length: { maximum: 25 },
        inclusion: { in: VIEW_STRATEGIES }

    def self.import(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
    
        CSV.foreach(file.path, headers: true) do |fields|
            group = Group.find_by_abbr(fields[1].to_s)

            if group
                mysyg_setting = group.mysyg_setting
                if mysyg_setting
                    mysyg_setting.mysyg_name                 = group.short_name.downcase
                    mysyg_setting.mysyg_enabled              = fields[2]
                    mysyg_setting.mysyg_open                 = fields[3]
                    mysyg_setting.participant_instructions   = fields[4]
                    mysyg_setting.extra_fee_total            = fields[5]
                    mysyg_setting.extra_fee_per_day          = fields[6]
                    mysyg_setting.show_sports_in_mysyg       = fields[7]
                    mysyg_setting.show_volunteers_in_mysyg   = fields[8]
                    mysyg_setting.show_finance_in_mysyg      = fields[9]  
                    mysyg_setting.show_group_extras_in_mysyg = fields[10]
                    mysyg_setting.approve_option             = fields[11]
                    mysyg_setting.team_sport_view_strategy   = fields[12]
                    mysyg_setting.indiv_sport_view_strategy  = fields[13]
                    mysyg_setting.mysyg_code                 = fields[14]
        
                    if mysyg_setting.save
                        updates += 1
                    else
                        errors += 1
                        error_list << mysyg_setting
                    end
                end
            end
        end
    
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end
end
