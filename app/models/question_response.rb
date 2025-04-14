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

  def full_answer
    if question.question_type == "Dropdown"
      if answer == nil || answer == "" || answer == "0"
        answer
      else
        option = QuestionOption.where(id: answer.to_i).first
        if option.nil?
          return nil
        else
          option.name.html_safe
        end
      end
    else
      if answer == nil
        answer
      else
        answer.html_safe
      end
    end
  end

  def self.create_responses(questions)
    responses = []

    questions.each do |question|
      response = QuestionResponse.new
      response.question = question
      responses << response
    end

    responses
  end
  
  def self.find_or_create_responses(participant, questions)
    responses = []

    questions.each do |question|
      response = QuestionResponse.find_or_create_by(participant: participant, question: question)
      responses << response
    end

    responses
  end
  
  def self.save_responses(participant, params)
    params.each do |key, value|
      if key.start_with?("question_id_")
        key_id = key.split("_").last.to_i
        answer_value = params["answer_#{key_id}"]
        question = Question.find(value.to_i)
        response = find_or_create_by(participant: participant, question: question)
        response.answer = answer_value

        # pp response
        response.save
      end
    end
  end
end
