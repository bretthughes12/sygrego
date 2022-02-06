# == Schema Information
#
# Table name: sessions
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  active         :boolean          default("true")
#  database_rowid :integer
#  updated_by     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_sessions_on_database_rowid  (database_rowid) UNIQUE
#  index_sessions_on_name            (name) UNIQUE
#

FactoryBot.define do
  factory :session do
    sequence(:name)             { |n| "Session#{n}"}
    sequence(:database_rowid)   { |n| n + 100 }
  end
end
