# == Schema Information
#
# Table name: pages
#
#  id         :bigint           not null, primary key
#  admin      :boolean
#  name       :string(50)
#  permalink  :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
    factory :page do
        name                        {"My page"}
        sequence(:permalink)        { |n| "my_page#{n}" }
        admin                       {true}
    end
end
