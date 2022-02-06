# == Schema Information
#
# Table name: audit_trails
#
#  id          :integer          not null, primary key
#  record_id   :integer
#  record_type :string(30)
#  event       :string(20)
#  user_id     :integer
#  created_at  :datetime
#

class AuditTrail < ApplicationRecord

end
