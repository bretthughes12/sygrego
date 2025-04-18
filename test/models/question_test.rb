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
require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
