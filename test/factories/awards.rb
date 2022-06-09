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
    category { "MyString" }
    submitted_by { "MyString" }
    submitted_group { "MyString" }
    name { "MyString" }
    description { "MyText" }
    flagged { false }
  end
end
