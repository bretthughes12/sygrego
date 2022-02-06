# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(40)       default(""), not null
#  group_role             :string(100)
#  address                :string(200)
#  suburb                 :string(40)
#  postcode               :integer          default("0")
#  phone_number           :string(30)
#  gc_reference           :string(40)
#  gc_reference_phone     :string(30)
#  years_as_gc            :integer          default("0")
#  primary_gc             :boolean          default("false")
#  status                 :string(12)       default("Not Verified")
#  wwcc_number            :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_name                  (name)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

FactoryBot.define do
  factory :user do
    sequence(:email)      { |n| "peter#{n}@piper.com" }
    sequence(:name)       { |n| "Peter Piper #{n}" }
    password              { "secret" }
    password_confirmation { "secret" }
    sequence(:phone_number) { |n| "555-#{n}"}
    sequence(:wwcc_number) { |n| "222222#{n}"}
    status                { "Verified" }

    trait :admin do
      roles               { [association(:role, :admin)] }
    end

    trait :church_rep do
      roles               { [association(:role, :church_rep)] }
    end

    trait :gc do
      roles               { [association(:role, :gc)] }
    end

    trait :participant do
      roles               { [association(:role, :participant)] }
    end
  end
end
