# == Schema Information
#
# Table name: roles
#
#  id                  :integer          not null, primary key
#  name                :string(20)
#  group_related       :boolean          default("false")
#  participant_related :boolean          default("false")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#

class Role < ApplicationRecord
    has_and_belongs_to_many :users

    validates :name,                   presence: true,
                                       length: { maximum: 20 }
end
