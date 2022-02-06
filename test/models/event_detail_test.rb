# == Schema Information
#
# Table name: event_details
#
#  id                 :integer          not null, primary key
#  onsite             :boolean          default("true")
#  fire_pit           :boolean          default("true")
#  camping_rqmts      :text
#  tents              :integer          default("0")
#  caravans           :integer          default("0")
#  marquees           :integer          default("0")
#  marquee_sizes      :string(255)
#  marquee_co         :string(50)
#  buddy_interest     :string(50)
#  buddy_comments     :text
#  service_pref_sat   :string(20)       default("No preference")
#  service_pref_sun   :string(20)       default("No preference")
#  estimated_numbers  :integer          default("0")
#  number_of_vehicles :integer          default("0")
#  updated_by         :integer
#  group_id           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_event_details_on_group_id  (group_id)
#

require "test_helper"

class EventDetailTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    @setting = FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @event_detail = FactoryBot.create(:event_detail)
  end

  test "should update exiting event details from file" do
    group = FactoryBot.create(:group, abbr: 'CAF')
    
    file = fixture_file_upload('event_detail.csv','application/csv')
    
    assert_no_difference('EventDetail.count') do
      @result = EventDetail.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    group.reload
    group.event_detail.reload
    assert_equal 34, group.event_detail.estimated_numbers
  end

  test "should not update event details with errors from file" do
    group = FactoryBot.create(:group, abbr: "CAF")
    event_detail = FactoryBot.create(:event_detail, group: group)
    file = fixture_file_upload('invalid_event_detail.csv','application/csv')
    
    assert_no_difference('EventDetail.count') do
      @result = EventDetail.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    group.reload
    group.event_detail.reload
    assert_not_equal "Not for us", group.event_detail.buddy_interest
  end
end
