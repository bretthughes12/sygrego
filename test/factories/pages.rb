# == Schema Information
#
# Table name: pages
#
#  id         :bigint           not null, primary key
#  admin_use  :boolean
#  name       :string(50)
#  permalink  :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pages_on_name       (name) UNIQUE
#  index_pages_on_permalink  (permalink) UNIQUE
#
FactoryBot.define do
    factory :page do
        sequence(:name)             { |n| "My page#{n}" }
        sequence(:permalink)        { |n| "my_page#{n}" }
        admin_use                   {true}
    end
end
