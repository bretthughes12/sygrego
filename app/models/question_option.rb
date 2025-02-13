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

end
