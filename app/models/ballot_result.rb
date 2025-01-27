# == Schema Information
#
# Table name: ballot_results
#
#  id                     :integer          not null, primary key
#  sport_name             :string(20)       not null
#  grade_name             :string(50)       not null
#  section_name           :string(50)
#  preferred_section_name :string(50)
#  entry_limit            :integer
#  over_limit             :boolean
#  one_entry_per_group    :boolean
#  group_name             :string(50)       not null
#  new_group              :boolean
#  sport_entry_name       :string
#  sport_entry_status     :string(20)       not null
#  factor                 :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class BallotResult < ApplicationRecord
    validates :sport_name,
        presence: true,
        length: { maximum: 20 }
    validates :grade_name,      
        presence: true,
        length: { maximum: 50 }
    validates :section_name,      
        length: { maximum: 50 }
    validates :preferred_section_name,      
        length: { maximum: 50 }
    validates :group_name,          
        presence: true,
        length: { maximum: 50 }
    validates :sport_entry_name,    
        length: { maximum: 255 }
    validates :sport_entry_status,  
        presence: true,
        length: { maximum: 20 }

    def self.summary
        BallotResult.group_names.collect do |group|
            BallotResult.group_result(group.group_name)
        end
    end

    def self.group_names
        BallotResult.select(:group_name).group(:group_name).order(:group_name)
    end

    def self.group_result(group_name)
        results = {}
        results[:group_name] = group_name
        results[:new_group] = new_group?(group_name)
        results[:number_entered] = count_of_entered(group_name)
        results[:number_to_confirm] = count_of_to_confirm(group_name)
        results[:number_missed_out] = count_of_missed_out(group_name)
        results
    end

    def self.new_group?(group_name)
        result = BallotResult.where(group_name: group_name).first
        result.nil? ? false : result.new_group
    end

    def self.count_of_entered(group_name)
        BallotResult.where(group_name: group_name, sport_entry_status: 'Entered').count
    end

    def self.count_of_to_confirm(group_name)
        BallotResult.where(group_name: group_name, sport_entry_status: 'To Be Confirmed').count
    end

    def self.count_of_missed_out(group_name)
        BallotResult.where(group_name: group_name, sport_entry_status: 'Waiting List').count
    end
end
