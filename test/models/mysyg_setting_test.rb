# == Schema Information
#
# Table name: mysyg_settings
#
#  id                         :integer          not null, primary key
#  mysyg_name                 :string(50)
#  mysyg_enabled              :boolean          default("false")
#  mysyg_open                 :boolean          default("false")
#  participant_instructions   :text
#  extra_fee_total            :decimal(8, 2)    default("0.0")
#  extra_fee_per_day          :decimal(8, 2)    default("0.0")
#  show_sports_in_mysyg       :boolean          default("true")
#  show_volunteers_in_mysyg   :boolean          default("true")
#  show_finance_in_mysyg      :boolean          default("true")
#  show_group_extras_in_mysyg :boolean          default("true")
#  approve_option             :string           default("Normal")
#  team_sport_view_strategy   :string           default("Show all")
#  indiv_sport_view_strategy  :string           default("Show all")
#  mysyg_code                 :string(25)
#  group_id                   :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_mysyg_settings_on_group_id  (group_id)
#

require "test_helper"

class MysygSettingTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    @setting = FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @mysyg_setting = FactoryBot.create(:mysyg_setting)
  end

  test "should update exiting MySYG settings from file" do
    group = FactoryBot.create(:group, abbr: 'CAF')
    
    file = fixture_file_upload('mysyg_setting.csv','application/csv')
    
    assert_no_difference('MysygSetting.count') do
      @result = MysygSetting.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    group.reload
    group.mysyg_setting.reload
    assert_equal "Tolerant", group.mysyg_setting.approve_option
  end

  test "should not update MySYG settings with errors from file" do
    group = FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('invalid_mysyg_setting.csv','application/csv')
    
    assert_no_difference('MysygSetting.count') do
      @result = MysygSetting.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    group.reload
    group.mysyg_setting.reload
    assert_not_equal "Invalid", group.mysyg_setting.approve_option
  end
end
