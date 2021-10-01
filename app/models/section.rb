# == Schema Information
#
# Table name: sections
#
#  id               :bigint           not null, primary key
#  active           :boolean
#  database_rowid   :integer
#  name             :string(50)       not null
#  number_in_draw   :integer
#  number_of_courts :integer          default(1)
#  updated_by       :bigint
#  year_introduced  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  grade_id         :integer          default(0), not null
#  session_id       :integer          default(0), not null
#  venue_id         :integer          default(0), not null
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (session_id => sessions.id)
#  fk_rails_...  (venue_id => venues.id)
#
class Section < ApplicationRecord
    include Comparable
    include Auditable

    require 'csv'
    require 'pp'
  
    attr_reader :file

#    has_many :officials, as: :coord_rqmt
#    has_many :sport_entries
    belongs_to :grade
    belongs_to :venue
    belongs_to :session
  
    scope :active, -> { where(active: true) }
  
    has_one_attached :draw_file

    delegate :name, to: :venue, prefix: 'venue'
    delegate :name, to: :session, prefix: 'session'
    delegate :sport_name, :sport, to: :grade
  
#    before_validation :clear_draw
#    before_save :set_database_rowid!
  
#    validates_attachment_content_type :draw, :content_type => ["application/pdf"]
  
    validates :name,                   presence: true,
                                       uniqueness: true,
                                       length: { maximum: 50 }
    validates :grade_id,               presence: true
    validates :venue_id,               presence: true
    validates :session_id,             presence: true
    validates :number_in_draw,         numericality: true,
                                       allow_blank: true
    validates :number_of_courts,       numericality: true,
                                       allow_blank: true
    validates :year_introduced,        numericality: true,
                                       allow_blank: true
#    validates :database_rowid,         uniqueness: true,
#                                       numericality: true,
#                                       allow_blank: true
  
    def <=>(other)
      name <=> other.name if other
    end
   
    def self.import(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
  
        CSV.foreach(file.path, headers: true) do |fields|
            grade = Grade.where(name: fields[1]).first
            venue = Venue.where(database_code: fields[4]).first
            session = Session.where(database_rowid: fields[7].to_i).first
    
            section = Section.find_by_name(fields[2].to_s)
            if section
                section.database_rowid          = fields[0].to_i
                section.grade                   = grade
                section.name                    = fields[2]
                section.active                  = fields[3]
                section.venue                   = venue
                section.year_introduced         = fields[5].to_i
                section.number_of_courts        = fields[6].to_i
                section.session                 = session
                section.updated_by              = user.id
 
                if section.save
                    updates += 1
                else
                    errors += 1
                    error_list << section
                end
            else
                section = Section.create(
                   database_rowid:          fields[0],
                   grade:                   grade,
                   name:                    fields[2],
                   active:                  fields[3],
                   venue:                   venue,
                   year_introduced:         fields[5].to_i,
                   number_of_courts:        fields[6].to_i,
                   session:                 session,
                   updated_by:              user.id)

                if section.errors.empty?
                    creates += 1
                else
                    errors += 1
                    error_list << section
                end
            end
        end
  
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end

  private

    def self.sync_fields
        ['name',
         'active',
         'database_rowid',
         'number_of_courts',
         'number_in_draw',
         'grade_id',
         'session_id',
         'venue_id'
        ]
    end
  end