# == Schema Information
#
# Table name: questions
#
#  id            :bigint           not null, primary key
#  description   :text
#  name          :string(50)       not null
#  order_number  :integer          default(1)
#  question_type :string(20)       not null
#  required      :boolean          default(FALSE)
#  section       :string(20)       not null
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  group_id      :bigint           not null
#
# Indexes
#
#  index_questions_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
class Question < ApplicationRecord
  belongs_to :group
  has_many :question_options, dependent: :destroy

  scope :personal, -> { where(section: 'Personal') }
  scope :medical, -> { where(section: 'Medical') }
  scope :camping, -> { where(section: 'Camping') }
  scope :sports, -> { where(section: 'Sports') }
  scope :driving, -> { where(section: 'Driving') }
  scope :disclaimer, -> { where(section: 'Disclaimer') }

  QUESTION_TYPES = [
    'Text',
    'Short Answer',
    'Paragraph',
    'Multiple Choice',
    'Checkboxes',
    'Dropdown'
  ].freeze

  SECTIONS = [
    'Personal',
    'Medical',
    'Camping',
    'Sports',
    'Driving',
    'Disclaimer'
  ].freeze

  validates :name,             
    presence: true,
    length: { maximum: 50 }
  validates :title,             
    presence: true,
    length: { maximum: 255 }
  validates :question_type,                
    presence: true,
    inclusion: { in: QUESTION_TYPES }, 
    length: { maximum: 20 }
  validates :section,                    
    presence: true,
    inclusion: { in: SECTIONS }, 
    numericality: { only_integer: true }

end
