# == Schema Information
#
# Table name: audit_trails
#
#  id          :bigint           not null, primary key
#  event       :string(20)
#  record_type :string(30)
#  created_at  :datetime
#  record_id   :integer
#  user_id     :integer
#
class AuditTrail < ActiveRecord::Base

end
