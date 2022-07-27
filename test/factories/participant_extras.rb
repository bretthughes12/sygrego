# == Schema Information
#
# Table name: participant_extras
#
#  id             :bigint           not null, primary key
#  comment        :string(255)
#  size           :string(10)
#  wanted         :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_extra_id :bigint           not null
#  participant_id :bigint           not null
#
# Indexes
#
#  index_participant_extras_on_group_extra_id  (group_extra_id)
#  index_participant_extras_on_participant_id  (participant_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_extra_id => group_extras.id)
#  fk_rails_...  (participant_id => participants.id)
#
FactoryBot.define do
  factory :participant_extra do
    participant { nil }
    group_extra { nil }
    wanted { true }
    size { "XL" }
    comment { "MyString" }
  end
end
