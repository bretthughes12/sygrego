# == Schema Information
#
# Table name: question_options
#
#  id           :bigint           not null, primary key
#  name         :string
#  order_number :integer          default(1)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  question_id  :bigint           not null
#
# Indexes
#
#  index_question_options_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#
class QuestionOption < ApplicationRecord
  belongs_to :question

  validates :name,             
    presence: true,
    length: { maximum: 255 }

  before_create :default_order!

  def move_up!
    prev = QuestionOption.where(question_id: self.question_id).where('order_number < ?', self.order_number).order(:order_number).last
    return unless prev

    prev.order_number, self.order_number = self.order_number, prev.order_number
    prev.save
    self.save
  end

  def move_down!
    next_option = QuestionOption.where(question_id: self.question_id).where('order_number > ?', self.order_number).order(:order_number).first
    return unless next_option

    next_option.order_number, self.order_number = self.order_number, next_option.order_number
    next_option.save
    self.save
  end
  
  private
  
  def default_order! 
    self.order_number = QuestionOption.where(question_id: self.question_id).maximum(:order_number).to_i + 1
  end
end
