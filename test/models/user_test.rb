# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
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
end