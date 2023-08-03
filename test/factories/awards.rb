# == Schema Information
#
# Table name: awards
#
#  id              :bigint           not null, primary key
#  category        :string(20)       not null
#  description     :text             not null
#  flagged         :boolean          default(FALSE)
#  name            :string(100)      not null
#  submitted_by    :string(100)      not null
#  submitted_group :string(100)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_awards_on_name  (name)
#
FactoryBot.define do
  factory :award do
    category          { "Spirit" }
    submitted_by      { "Madonna" }
    submitted_group   { "Caffeine" }
    name              { "Admin team" }
    description       { "Did awesome stuff" }
    flagged           { false }
  end

  trait :good_sports do
    category          { "Good Sports" }
  end

  trait :spirit do
    category          { "Spirit" }
  end

  trait :volunteer do
    category          { "Volunteer" }
  end
end
