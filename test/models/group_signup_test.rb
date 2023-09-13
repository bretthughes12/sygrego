require "test_helper"

class GroupSignupTest < ActiveSupport::TestCase

  def setup
    FactoryBot.create(:role, name: 'admin')
    @gc_role = FactoryBot.create(:role, name: 'gc')
    @cr_role = FactoryBot.create(:role, name: 'church_rep')
    @user = FactoryBot.create(:user)
    FactoryBot.create(:setting)
  end

  test "should create a new group and users" do
    gs = GroupSignup.new(FactoryBot
      .attributes_for(:group_signup))

    assert_equal true, gs.group.new_record?
    assert_equal true, gs.gc.new_record?
    assert_equal true, gs.church_rep.new_record?
  end

  test "should update existing group and create new users" do
    group = FactoryBot.create(:group)

    gs = GroupSignup.new(FactoryBot
      .attributes_for(:group_signup,
        name: group.name))

    assert_equal false, gs.group.new_record?
    assert_equal true, gs.gc.new_record?
    assert_equal true, gs.church_rep.new_record?
  end

  test "should create new group and update existing users" do
    gc = FactoryBot.create(:user)
    gc.roles << @gc_role
    cr = FactoryBot.create(:user)
    cr.roles << @cr_role

    gs = GroupSignup.new(FactoryBot
      .attributes_for(:group_signup,
        church_rep_email: cr.email,
        gc_email: gc.email))

    assert_equal true, gs.group.new_record?
    assert_equal false, gs.gc.new_record?
    assert_equal false, gs.church_rep.new_record?
  end

  test "should not save with an invalid group" do
    GroupSignup.any_instance.stubs(:valid?).returns(true)

    ps = GroupSignup.new(FactoryBot
      .attributes_for(:group_signup, 
        email: "a"))

    assert_equal false, ps.save
  end

  test "should not save with an invalid church rep" do
    GroupSignup.any_instance.stubs(:valid?).returns(true)

    ps = GroupSignup.new(FactoryBot
      .attributes_for(:group_signup, 
        church_rep_email: "a"))

    assert_equal false, ps.save
  end

  test "should not save with an invalid gc" do
    GroupSignup.any_instance.stubs(:valid?).returns(true)

    ps = GroupSignup.new(FactoryBot
      .attributes_for(:group_signup, 
        gc_email: "a"))

    assert_equal false, ps.save
  end
end