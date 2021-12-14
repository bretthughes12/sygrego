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
# Indexes
#
#  index_groups_on_abbr          (abbr) UNIQUE
#  index_groups_on_name          (name) UNIQUE
#  index_groups_on_short_name    (short_name) UNIQUE
#  index_groups_on_trading_name  (trading_name) UNIQUE
#
require "test_helper"

class GroupTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:role, name: 'admin')
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

  def test_group_deposit
    # group expects fewer than 20 (small group)
    group = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 19, 
      group: group)
    assert_equal 150, group.deposit

    # group expects no one coming
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 0, 
      group: group)
    assert_equal 150, group.deposit
    
    # medium group 
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group)
    assert_equal 300, group.deposit
    
    # medium group (upper boundary)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 39, 
      group: group)
    assert_equal 300, group.deposit
    
    # large
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 40, 
      group: group)
    assert_equal 600, group.deposit
    
    # admin
    group.admin_use = true
    assert_equal 0, group.deposit
  end

  def test_group_fees
    #group has people registered
    group = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group)
    5.times do
      FactoryBot.create(:participant, 
                     group: group, 
                     coming: true)
    end
    group.reload

    assert group.fees > @setting.full_fee
    
    #group has one participant, who is not coming
    group_with_noone_coming = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group_with_noone_coming)
    FactoryBot.create(:participant, 
                   group: group_with_noone_coming, 
                   coming: false)
    group_with_noone_coming.reload

    assert_equal 0, group_with_noone_coming.fees
    
    #group has one normal camper
    group_with_one_coming = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group_with_one_coming)
    FactoryBot.create(:participant, 
                   group: group_with_one_coming, 
                   coming: true)
    group_with_one_coming.reload

    assert_equal 0, group_with_one_coming.fees
    
    #group with no participants
    group_with_no_participants = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group_with_no_participants)

    assert_equal 0, group_with_no_participants.fees
  end

  test "should allow 2 group coordinators" do
    #at present this is always '2'
    assert_equal 2, @group.coordinators_allowed
  end

  def test_division_boundaries
    #Small church
    small_church = FactoryBot.create(:group)
    @setting.small_division_ceiling.times do
      FactoryBot.create(:participant, 
                     group: small_church, 
                     coming: true, 
                     spectator: false)  
    end
    small_church.reload

    assert_equal "Small Churches", small_church.division
    assert_equal 2, small_church.free_helpers

    #Medium church
    medium_church_low = FactoryBot.create(:group)
    (@setting.small_division_ceiling + 1).times do
      FactoryBot.create(:participant, 
                     group_id: medium_church_low.id, 
                     coming: true, 
                     spectator: false)  
    end
    medium_church_low.reload

    medium_church_high = FactoryBot.create(:group)
    @setting.medium_division_ceiling.times do
      FactoryBot.create(:participant, 
                     group: medium_church_high, 
                     coming: true, 
                     spectator: false)  
    end
    medium_church_high.reload

    assert_equal "Medium Churches", medium_church_low.division
    assert_equal "Medium Churches", medium_church_high.division
    assert_equal 4, medium_church_low.free_helpers
    
    #Large church
    large_church = FactoryBot.create(:group)
    (@setting.medium_division_ceiling + 1).times do
      FactoryBot.create(:participant, 
                     group: large_church, 
                     coming: true, 
                     spectator: false)  
    end
    large_church.reload

    assert_equal "Large Churches", large_church.division
    assert_equal 6, large_church.free_helpers
  end
  
  test "divisions should list all groups" do
    FactoryBot.create(:group)
    divisions = Group.divisions

    assert divisions["Small Churches"] > 0
  end
  
  test "group divisions should include all groups" do
    group = FactoryBot.create(:group)
    divisions = Group.group_divisions

    assert_equal "Small Churches", divisions[group.id]
  end

  test "should show mysyg status" do
    ms = FactoryBot.create(:mysyg_setting, mysyg_open: true)
    assert_equal 'Open', ms.group.mysyg_status

    ms.mysyg_open = false
    ms.mysyg_enabled = true
    assert_equal 'Enabled', ms.group.mysyg_status

    ms.mysyg_enabled = false
    assert_equal 'Not enabled', ms.group.mysyg_status
  end

  test "should determine participants allowed per session" do
    # based on estimated numbers
    ed = FactoryBot.create(:event_detail, estimated_numbers: 10)
    assert_equal 15, ed.group.participants_allowed_per_session

    # based on actual numbers
    12.times do
      FactoryBot.create(:participant, group: ed.group)
    end
    ed.group.reload
    assert_equal 18, ed.group.participants_allowed_per_session
  end

  test "should calculate the number playing sport" do
    group = FactoryBot.create(:group)
    12.times do
      FactoryBot.create(:participant, 
        group: group,
        spectator: false,
        status: 'Accepted',
        coming: true)
    end
    group.reload
    assert_equal 12, group.number_playing_sport
  end

  test "should determine helpers allowed" do
    # basic number
    group = FactoryBot.create(:group)
    assert_equal 4, group.helpers_allowed

    # larger groups
    40.times do
      FactoryBot.create(:participant, 
        group: group,
        spectator: false,
        status: 'Accepted',
        coming: true)
    end
    group.reload
    assert_equal 6, group.helpers_allowed
  end

  test "should calculate the helper rebate" do
    group = FactoryBot.create(:group)
    80.times do
      FactoryBot.create(:participant, 
        group: group,
        spectator: false,
        status: 'Accepted',
        coming: true)
    end
    8.times do
      FactoryBot.create(:participant, 
        group: group,
        spectator: true,
        helper: true,
        status: 'Accepted',
        coming: true)
    end

    group.reload
    assert_equal 180, group.helper_rebate
  end

  test "should aggregate church reps" do
    cr_role = FactoryBot.create(:role, "church_rep")
    cr1 = FactoryBot.create(:user)
    cr2 = FactoryBot.create(:user)
    cr1.roles << cr_role
    cr2.roles << cr_role
    gc = FactoryBot.create(:user, :gc)
    @group.users << cr1
    @group.users << cr2
    @group.users << gc

    assert @group.church_reps.include?(cr1)
    assert @group.church_reps.include?(cr2)
    assert !@group.church_reps.include?(gc)
    assert_equal cr1, @group.church_rep
    assert_equal cr1.name, @group.church_rep_name
    assert_equal cr1.phone_number, @group.church_rep_phone_number
    assert_equal cr1.wwcc_number, @group.church_rep_wwcc
  end

  test "should aggregate gcs" do
    gc_role = FactoryBot.create(:role, "gc")
    cr = FactoryBot.create(:user, :church_rep)
    gc1 = FactoryBot.create(:user)
    gc2 = FactoryBot.create(:user)
    gc1.roles << gc_role
    gc2.roles << gc_role
    @group.users << cr
    @group.users << gc1
    @group.users << gc2

    assert @group.gcs.include?(gc1)
    assert @group.gcs.include?(gc2)
    assert !@group.gcs.include?(cr)
    assert_equal gc1, @group.gc
    assert_equal gc1.name, @group.gc_name
    assert_equal gc1.phone_number, @group.gc_phone_number
    assert_equal gc1.wwcc_number, @group.gc_wwcc
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

  test "should retrieve the default group" do
    group = FactoryBot.create(:group, abbr: "DFLT")
    
    assert_equal group, Group.default_group
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

  test "should import groups from file" do
    file = fixture_file_upload('group.csv','application/csv')
    
    assert_difference('Group.count') do
      @result = Group.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting groups from file" do
    group = FactoryBot.create(:group, abbr: 'CAF')
    file = fixture_file_upload('group.csv','application/csv')
    
    assert_no_difference('Group.count') do
      @result = Group.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    group.reload
    assert_equal "Caffeine", group.short_name
  end

  test "should not import groups with errors from file" do
    file = fixture_file_upload('invalid_group.csv','application/csv')
    
    assert_no_difference('Group.count') do
      @result = Group.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update groups with errors from file" do
    group = FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('invalid_group.csv','application/csv')
    
    assert_no_difference('Group.count') do
      @result = Group.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    group.reload
    assert_not_equal "Invalid", group.status
  end

  # Tests for searchable concern
  test "should search groups for matching :abbr" do
    groups = Group.search(@group.abbr)

    assert_equal true, groups.include?(@group)
  end

  test "should return empty when no match on search groups" do
    groups = Group.search("ZZZZ")

    assert_equal true, groups.empty?
  end
end
