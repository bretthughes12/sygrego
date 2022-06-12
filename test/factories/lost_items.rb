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
#  phone_number :string(30)
#  postcode     :integer
#  suburb       :string(40)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :lost_item do
    category { "MyString" }
    description { "MyString" }
    claimed { false }
    name { "MyString" }
    address { "MyString" }
    suburb { "MyString" }
    postcode { 1 }
    phone_number { "MyString" }
    email { "MyString" }
    lock_version { 1 }
  end
end
