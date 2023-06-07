# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  address                :string(200)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  gc_reference           :string(40)
#  gc_reference_phone     :string(30)
#  group_role             :string(100)
#  name                   :string(40)       default(""), not null
#  phone_number           :string(30)
#  postcode               :integer          default(0)
#  primary_gc             :boolean          default(FALSE)
#  protect_password       :boolean          default(FALSE)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  status                 :string(12)       default("Not Verified")
#  suburb                 :string(40)
#  wwcc_number            :string
#  years_as_gc            :integer          default(0)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
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
