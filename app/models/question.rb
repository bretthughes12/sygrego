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
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  group_id      :bigint           not null
#
# Indexes
#
#  index_questions_on_group_id                               (group_id)
#  index_questions_on_group_id_and_section_and_order_number  (group_id,section,order_number)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
class Question < ApplicationRecord
  belongs_to :group
  has_many :question_options, dependent: :destroy
  has_many :question_responses, dependent: :destroy

  scope :beginning, -> { where(section: 'Start') }
  scope :personal, -> { where(section: 'Personal') }
  scope :medical, -> { where(section: 'Medical') }
  scope :camping, -> { where(section: 'Camping') }
  scope :sports, -> { where(section: 'Sports') }
  scope :driving, -> { where(section: 'Driving') }
  scope :disclaimer, -> { where(section: 'Disclaimer') }
  scope :with_answer, -> { where("question_type not in ('Heading', 'Text')") }


  # TODO: Sort out css around checkboxes and radio buttons and enable 'Multiple Choice' and 'Checkboxes' question types
  QUESTION_TYPES = [
    'Heading',
    'Text',
    'Short Answer',
    'Paragraph',
    'Checkbox',
    'Dropdown'
  ].freeze

  SECTIONS = [
    'Start',  
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
  validates :question_type,                
    presence: true,
    inclusion: { in: QUESTION_TYPES }, 
    length: { maximum: 20 }
  validates :section,                    
    presence: true,
    inclusion: { in: SECTIONS }

  before_create :default_order!
  before_update :check_if_section_changed

  def move_up!
    prev = Question.where(group_id: self.group_id, section: self.section).where('order_number < ?', self.order_number).order(:order_number).last
    return unless prev

    prev.order_number, self.order_number = self.order_number, prev.order_number
    prev.save
    self.save
  end

  def move_down!
    next_question = Question.where(group_id: self.group_id, section: self.section).where('order_number > ?', self.order_number).order(:order_number).first
    return unless next_question

    next_question.order_number, self.order_number = self.order_number, next_question.order_number
    next_question.save
    self.save
  end

private

  def default_order! 
    self.order_number = Question.where(group_id: self.group_id, section: self.section).maximum(:order_number).to_i + 1
  end

  def check_if_section_changed
    if section_changed? 
      default_order!
    end
  end


end
