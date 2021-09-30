# == Schema Information
#
# Table name: groups
#
#  id               :bigint           not null, primary key
#  abbr             :string(4)        not null
#  address          :string(200)      not null
#  admin_use        :boolean
#  age_demographic  :string(40)
#  allocation_bonus :integer          default(0)
#  coming           :boolean          default(TRUE)
#  database_rowid   :integer
#  denomination     :string(40)       not null
#  email            :string(100)
#  group_focus      :string(100)
#  last_year        :boolean
#  late_fees        :decimal(8, 2)    default(0.0)
#  lock_version     :integer          default(0)
#  name             :string(100)      not null
#  new_group        :boolean          default(TRUE)
#  phone_number     :string(20)
#  postcode         :integer          not null
#  short_name       :string(50)       not null
#  status           :string(12)       default("Stale")
#  suburb           :string(40)       not null
#  trading_name     :string(100)      not null
#  updated_by       :bigint
#  website          :string(100)
#  years_attended   :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
FactoryBot.define do
  factory :group do
    sequence(:abbr)       { |n| "T#{n%990 + 10}" }
    sequence(:name)       { |n| "Test group#{n}" }
    sequence(:short_name) { |n| "Test#{n}" }
    trading_name          {"Test trading name"}
    address               {"123 Main St"}
    suburb                {"Maintown"}
    postcode              {"3999"}
    coming                {true}
    phone_number          {"0395557777"}
    sequence(:email)      { |n| "group#{n}email@email.com" }
    sequence(:website)    { |n| "www.group#{n}.com" }      
    denomination          {"Baptist"}
  end
end
