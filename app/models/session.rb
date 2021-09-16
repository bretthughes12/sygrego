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

    require 'csv'
  
    attr_reader :file

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

    def self.import(file, user)
      CSV.foreach(file.path, headers: true) do |fields|
        session = Session.find_by_database_rowid(fields[0].to_i)
        if session
          session.database_rowid = fields[0]
          session.active = fields[1]
          session.name = fields[2]
          session.updated_by = user.id
          
          if session.save
            puts "Updated session #{fields[2]}"
          else
            puts "Session update failed: #{fields[2]}"
#            pp session.errors                        
          end
        else
          session = Session.create(database_rowid: fields[0],
                                   active:         fields[1],
                                   name:           fields[2],
                                   updated_by:     user.id)

          if session.errors.empty?
            puts "Created session #{fields[2]}"
          else
            puts "Session create failed: #{fields[2]}"
#            pp session.errors                        
          end
        end
      end
    end

    private

    def self.sync_fields
        ['database_rowid',
         'name']
    end
end
