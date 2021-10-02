# == Schema Information
#
# Table name: roles
#
#  id         :bigint           not null, primary key
#  name       :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer
#
class Role < ApplicationRecord
    has_and_belongs_to_many :users
end
