# == Schema Information
#
# Table name: lost_items
#
#  id           :bigint           not null, primary key
#  address      :string(200)
#  category     :string(30)       not null
#  claimed      :boolean          default(FALSE)
#  description  :string(255)      not null
#  email        :string(100)
#  lock_version :integer          default(0)
#  name         :string(40)
#  notes        :text
#  phone_number :string(30)
#  postcode     :integer
#  suburb       :string(40)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :lost_item do
    category    { "Stuff" }
    description { "Dooverlackey" }
    claimed     { false }
  end

  trait :claimed do
    claimed         { true }
    sequence(:name) { |n| "Mary Jones#{n}"}
    address         { "123 Main St" }
    suburb          { "Disneyland" }
    postcode        { 3000 }
    phone_number    { "9555-4444" }
    email           { "My@String.com" }
  end
end
