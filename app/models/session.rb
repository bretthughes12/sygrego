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
# Indexes
#
#  index_sessions_on_database_rowid  (database_rowid) UNIQUE
#  index_sessions_on_name            (name) UNIQUE
#
class Session < ApplicationRecord
    include Comparable
    include Auditable

    require 'csv'
  
    attr_reader :file

    has_many :sections
  
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
      creates = 0
      updates = 0
      errors = 0
      error_list = []

      CSV.foreach(file.path, headers: true) do |fields|
        session = Session.find_by_database_rowid(fields[0].to_i)
        if session
          session.database_rowid = fields[0]
          session.active = fields[1]
          session.name = fields[2]
          session.updated_by = user.id
          
          if session.save
            updates += 1
          else
            errors += 1
            error_list << session
          end
        else
          session = Session.create(database_rowid: fields[0],
                                   active:         fields[1],
                                   name:           fields[2],
                                   updated_by:     user.id)

          if session.errors.empty?
            creates += 1
          else
            errors += 1
            error_list << session
          end
        end
      end

      { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end

    private

    def self.sync_fields
        ['database_rowid',
         'name']
    end
end
