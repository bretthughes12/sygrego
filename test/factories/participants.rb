# == Schema Information
#
# Table name: participants
#
#  id                     :integer          not null, primary key
#  group_id               :integer          default("0"), not null
#  first_name             :string(20)       not null
#  surname                :string(20)       not null
#  coming                 :boolean          default("true")
#  age                    :integer          default("30"), not null
#  gender                 :string(1)        default("M"), not null
#  days                   :integer          default("3"), not null
#  address                :string(200)
#  suburb                 :string(40)
#  postcode               :integer
#  phone_number           :string(20)
#  medical_info           :string(255)
#  medications            :string(255)
#  years_attended         :integer
#  database_rowid         :integer
#  lock_version           :integer          default("0")
#  spectator              :boolean          default("false")
#  onsite                 :boolean          default("true")
#  helper                 :boolean          default("false")
#  group_coord            :boolean          default("false")
#  sport_coord            :boolean          default("false")
#  guest                  :boolean          default("false")
#  withdrawn              :boolean          default("false")
#  fee_when_withdrawn     :decimal(8, 2)    default("0.0")
#  late_fee_charged       :boolean          default("false")
#  driver                 :boolean          default("false")
#  number_plate           :string(10)
#  early_bird             :boolean          default("false")
#  email                  :string(100)
#  mobile_phone_number    :string(20)
#  dietary_requirements   :string(255)
#  emergency_contact      :string(40)
#  emergency_relationship :string(20)
#  emergency_phone_number :string(20)
#  amount_paid            :decimal(8, 2)    default("0.0")
#  status                 :string(20)       default("Accepted")
#  driver_signature       :boolean          default("false")
#  driver_signature_date  :datetime
#  updated_by             :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  wwcc_number            :string
#  medicare_number        :string
#
# Indexes
#
#  index_participants_on_coming                               (coming)
#  index_participants_on_group_id_and_surname_and_first_name  (group_id,surname,first_name) UNIQUE
#  index_participants_on_surname_and_first_name               (surname,first_name)
#

FactoryBot.define do
  factory :participant do
    group

    sequence(:first_name) { |n| "Johnny#{n}"}
    sequence(:surname)    { |n| "Smith#{n}"}
    age                   {"18"}
    gender                {"M"}
    days                  {"3"}
    coming                {true}
    address               {"123 Main St"}
    suburb                {"Disneyland"}
    postcode              {"3333"}
    email                 {"blah@blah.com"}
    phone_number          {"9555-5555"}
  end
end
