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
#  jti                    :string           not null
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
#  index_users_on_jti                   (jti) UNIQUE
#  index_users_on_name                  (name)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class ApiUser < User
  
end
