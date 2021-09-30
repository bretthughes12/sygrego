# == Schema Information
#
# Table name: groups
#
#  id               :bigint           not null, primary key
#  abbr             :string(4)        not null
#  address          :string(200)      not null
#  admin_use        :boolean
#  age_demographic  :string(40)
#  allocation_bonus :integer          default(0)
#  coming           :boolean          default(TRUE)
#  database_rowid   :integer
#  denomination     :string(40)       not null
#  email            :string(100)
#  group_focus      :string(100)
#  last_year        :boolean
#  late_fees        :decimal(8, 2)    default(0.0)
#  lock_version     :integer          default(0)
#  name             :string(100)      not null
#  new_group        :boolean          default(TRUE)
#  phone_number     :string(20)
#  postcode         :integer          not null
#  short_name       :string(50)       not null
#  status           :string(12)       default("Stale")
#  suburb           :string(40)       not null
#  trading_name     :string(100)      not null
#  updated_by       :bigint
#  website          :string(100)
#  years_attended   :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"

class GroupTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @group = FactoryBot.create(:group, name: "Order1")
  end

  test "should compare groups" do
    #comparison against self
    assert_equal 0, @group <=> @group 
    #different name
    other_group = FactoryBot.create(:group, name: "Order2")
    assert_equal -1, @group <=> other_group
  end

  test "should allow 2 group coordinators" do
    #at present this is always '2'
    assert_equal 2, @group.coordinators_allowed
  end

  test "should assign short name" do
    FactoryBot.create(:group, short_name: "Aaaargh")
    
    #Normal use - returns first word of name
    assert_equal "Aaaa", Group.assign_short_name("Aaaa Church of Christ")
    #First name is already taken - returns first and second words of name
    assert_equal "Aaaargh Church", Group.assign_short_name("Aaaargh Church of Christ")
    #First name is already taken and ther is no second name
    assert_equal "Aaaargh1", Group.assign_short_name("Aaaargh")
  end

  test "should assign abbreviation" do
    FactoryBot.create(:group, abbr: "BB")
    
    #Normal use - returns first letter of the first four words of name
    assert_equal "ACOC", Group.assign_abbr("Aaaa Church of Christ")
    #Abbreviation is already taken - returns the next available abbreviation
    assert_equal "BC", Group.assign_abbr("Baaargh Baa")
    #Short Abbreviation - Duplicates until long enough
    assert_equal "AA", Group.assign_abbr("Aaaargh")
    #Shorter AND a duplication - Duplicates as well as finding the next one
    assert_equal "BC", Group.assign_abbr("Baaargh")
  end

  test "should reset allocation bonus" do
    g = FactoryBot.create(:group, allocation_bonus: 99)
    g.reset_allocation_bonus!

    g.reload
    assert_equal 0, g.allocation_bonus
  end

  test "should increment allocation bonus" do
    g = FactoryBot.create(:group, allocation_bonus: 0)
    g.increment_allocation_bonus!

    g.reload
    assert_equal @setting.missed_out_sports_allocation_factor, g.allocation_bonus
  end
end
