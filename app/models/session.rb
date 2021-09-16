# == Schema Information
#
# Table name: sessions
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(TRUE)
#  database_rowid :integer
#  name           :string           not null
#  updated_by     :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Session < ApplicationRecord
    include Comparable
    include Auditable
  
#    has_many :sport_grades
  
    scope :active, -> { where(active: true) }
  
    validates :name,                   presence: true,
                                       uniqueness: true,
                                       length: { maximum: 50 }
    validates :database_rowid,         presence: true,
                                       uniqueness: true,
                                       numericality: true
    
    def <=>(other)
      id <=> other.id
    end
  
    def self.session_names
      Session.active.order(:id).collect(&:name)
    end
  
    def self.total_sessions
      Session.active.count
    end

    private

    def self.sync_fields
        ['database_rowid',
         'name']
    end
end
