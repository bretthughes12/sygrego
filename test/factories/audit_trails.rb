# == Schema Information
#
# Table name: audit_trails
#
#  id          :bigint           not null, primary key
#  event       :string(20)
#  record_type :string(30)
#  created_at  :datetime
#  record_id   :bigint
#  user_id     :bigint
#

FactoryBot.define do
    factory :audit_trail do 
        sequence(:record_id)  { |n| n }
        event                 {"UPDATE"}
        record_type           {"Group"}
        user_id               {1}
    end
end    
