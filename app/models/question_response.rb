# == Schema Information
#
# Table name: question_responses
#
#  id             :bigint           not null, primary key
#  answer         :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  participant_id :bigint           not null
#  question_id    :bigint           not null
#
# Indexes
#
#  index_question_responses_on_participant_id  (participant_id)
#  index_question_responses_on_question_id     (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (participant_id => participants.id)
#  fk_rails_...  (question_id => questions.id)
#
class QuestionResponse < ApplicationRecord
  belongs_to :participant
  belongs_to :question
end
