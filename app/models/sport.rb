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
