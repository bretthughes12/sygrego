# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(40)       default(""), not null
#  group_role             :string(100)
#  address                :string(200)
#  suburb                 :string(40)
#  postcode               :integer          default("0")
#  phone_number           :string(30)
#  gc_reference           :string(40)
#  gc_reference_phone     :string(30)
#  years_as_gc            :integer          default("0")
#  primary_gc             :boolean          default("false")
#  status                 :string(12)       default("Not Verified")
#  wwcc_number            :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_name                  (name)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
  end
    
  test "should indicate when user has a role" do
    role = FactoryBot.create(:role, name: 'joker')
    user = FactoryBot.create(:user)
    user.roles << role

    user.reload
    assert_equal true, user.role?('joker')
  end

  test "should indicate when user does not have a role" do
    role = FactoryBot.create(:role, name: 'joker')
    user = FactoryBot.create(:user)
    user.roles << role

    user.reload
    assert_equal false, user.role?('batman')
  end

  test "should default role to participant when only that role" do
    user = FactoryBot.create(:user, :participant)

    user.reload
    assert_equal :participant, user.default_role
  end

  test "should default role to gc when both gc and participant" do
    role1 = FactoryBot.create(:role, name: 'participant')
    role2 = FactoryBot.create(:role, name: 'gc')
    user = FactoryBot.create(:user)
    user.roles << role1
    user.roles << role2

    user.reload
    assert_equal :gc, user.default_role
  end

  test "should default role to church_rep when both gc and church_rep" do
    role1 = FactoryBot.create(:role, name: 'church_rep')
    role2 = FactoryBot.create(:role, name: 'gc')
    user = FactoryBot.create(:user)
    user.roles << role1
    user.roles << role2

    user.reload
    assert_equal :church_rep, user.default_role
  end

  test "should default role to admin when admin and anything else" do
    role1 = FactoryBot.create(:role, name: 'participant')
    role2 = FactoryBot.create(:role, name: 'gc')
    admin_role = Role.find_by_name('admin')
    user = FactoryBot.create(:user)
    user.roles << admin_role
    user.roles << role1
    user.roles << role2

    user.reload
    assert_equal :admin, user.default_role
  end
end
