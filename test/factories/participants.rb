# == Schema Information
#
# Table name: participants
#
#  id                           :bigint           not null, primary key
#  address                      :string(200)
#  age                          :integer          default(30), not null
#  amount_paid                  :decimal(8, 2)    default(0.0)
#  coming                       :boolean          default(TRUE)
#  database_rowid               :integer
#  days                         :integer          default(3), not null
#  dietary_requirements         :string(255)
#  driver                       :boolean          default(FALSE)
#  driver_signature             :boolean          default(FALSE)
#  driver_signature_date        :datetime
#  early_bird                   :boolean          default(FALSE)
#  email                        :string(100)
#  emergency_contact            :string(40)
#  emergency_phone_number       :string(20)
#  emergency_relationship       :string(20)
#  encrypted_medicare_number    :string
#  encrypted_medicare_number_iv :string
#  encrypted_wwcc_number        :string
#  encrypted_wwcc_number_iv     :string
#  fee_when_withdrawn           :decimal(8, 2)    default(0.0)
#  first_name                   :string(20)       not null
#  gender                       :string(1)        default("M"), not null
#  group_coord                  :boolean          default(FALSE)
#  guest                        :boolean          default(FALSE)
#  helper                       :boolean          default(FALSE)
#  late_fee_charged             :boolean          default(FALSE)
#  lock_version                 :integer          default(0)
#  medical_info                 :string(255)
#  medications                  :string(255)
#  mobile_phone_number          :string(20)
#  number_plate                 :string(10)
#  onsite                       :boolean          default(TRUE)
#  phone_number                 :string(20)
#  postcode                     :integer
#  spectator                    :boolean          default(FALSE)
#  sport_coord                  :boolean          default(FALSE)
#  status                       :string(20)       default("Accepted")
#  suburb                       :string(40)
#  surname                      :string(20)       not null
#  updated_by                   :bigint
#  withdrawn                    :boolean          default(FALSE)
#  years_attended               :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  group_id                     :bigint           default(0), not null
#
# Indexes
#
#  index_participants_on_coming                               (coming)
#  index_participants_on_group_id_and_surname_and_first_name  (group_id,surname,first_name) UNIQUE
#  index_participants_on_surname_and_first_name               (surname,first_name)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
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