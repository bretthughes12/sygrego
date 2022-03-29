# == Schema Information
#
# Table name: group_extras
#
#  id             :bigint           not null, primary key
#  comment_prompt :string
#  cost           :decimal(8, 2)
#  name           :string(20)       not null
#  needs_size     :boolean          default(FALSE)
#  optional       :boolean          default(TRUE)
#  show_comment   :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_id       :bigint           not null
#
# Indexes
#
#  index_group_extras_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
FactoryBot.define do
  factory :group_extra do
    group { nil }
    name { "MyString" }
    needs_size { false }
    cost { "9.99" }
    optional { false }
    show_comment { false }
    comment_prompt { "MyString" }
  end
end
