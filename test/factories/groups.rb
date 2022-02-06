# == Schema Information
#
# Table name: groups
#
#  id               :integer          not null, primary key
#  abbr             :string(4)        not null
#  name             :string(100)      not null
#  short_name       :string(50)       not null
#  coming           :boolean          default("true")
#  lock_version     :integer          default("0")
#  database_rowid   :integer
#  new_group        :boolean          default("true")
#  trading_name     :string(100)      not null
#  address          :string(200)      not null
#  suburb           :string(40)       not null
#  postcode         :integer          not null
#  phone_number     :string(20)
#  last_year        :boolean          default("false")
#  admin_use        :boolean          default("false")
#  late_fees        :decimal(8, 2)    default("0.0")
#  allocation_bonus :integer          default("0")
#  email            :string(100)
#  website          :string(100)
#  denomination     :string(40)       not null
#  years_attended   :integer          default("0")
#  status           :string(12)       default("Stale")
#  age_demographic  :string(40)
#  group_focus      :string(100)
#  updated_by       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_groups_on_abbr          (abbr) UNIQUE
#  index_groups_on_name          (name) UNIQUE
#  index_groups_on_short_name    (short_name) UNIQUE
#  index_groups_on_trading_name  (trading_name) UNIQUE
#

FactoryBot.define do
  factory :group do
    sequence(:abbr)       { |n| "T#{n%990 + 10}" }
    sequence(:name)       { |n| "Test group#{n}" }
    sequence(:short_name) { |n| "Test#{n}" }
    sequence(:trading_name)  { |n| "Test trading name#{n}" }
    address               {"123 Main St"}
    suburb                {"Maintown"}
    postcode              {"3999"}
    coming                {true}
    phone_number          {"0395557777"}
    sequence(:email)      { |n| "group#{n}email@email.com" }
    sequence(:website)    { |n| "www.group#{n}.com" }      
    denomination          {"Baptist"}
    status                {"Approved"}
  end
end
