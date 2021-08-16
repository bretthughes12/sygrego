# == Schema Information
#
# Table name: sports
#
#  id                      :bigint           not null, primary key
#  active                  :boolean          default(TRUE)
#  bonus_for_officials     :boolean          default(FALSE)
#  classification          :string(10)       not null
#  court_name              :string(20)       default("Court")
#  draw_type               :string(20)       not null
#  lock_version            :integer          default(0)
#  max_entries_indiv       :integer          default(0), not null
#  max_indiv_entries_group :integer          default(0), not null
#  max_team_entries_group  :integer          default(0), not null
#  name                    :string(20)       not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
end
#
class Sport < ApplicationRecord
    include Comparable

    CLASSIFICATIONS = %w[Individual
                         Team]

    DRAW_TYPES = ['Knockout',
                  'Open',
                  'Round Robin']

    validates :name,                    presence: true,
                                        uniqueness: { case_sensitive: false },
                                        length: { maximum: 20 }
    validates :max_indiv_entries_group, presence: true,
                                        numericality: { only_integer: true }
    validates :max_team_entries_group,  presence: true,
                                        numericality: { only_integer: true }
    validates :max_entries_indiv,       presence: true,
                                        numericality: { only_integer: true }
    validates :classification,          presence: true,
                                        length: { maximum: 10 },
                                        inclusion: { in: CLASSIFICATIONS }
    validates :draw_type,               presence: true,
                                        length: { maximum: 20 },
                                        inclusion: { in: DRAW_TYPES }
    validates :court_name,              length: { maximum: 20 }

    def self.per_page
        15
    end

    def <=>(other)
        name <=> other.name
    end
    
    def max_entries_group
        max_indiv_entries_group + max_team_entries_group
    end
    
end
