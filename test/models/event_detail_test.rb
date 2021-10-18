# == Schema Information
#
# Table name: event_details
#
#  id                 :bigint           not null, primary key
#  buddy_comments     :text
#  buddy_interest     :string(50)
#  camping_rqmts      :text
#  caravans           :integer          default(0)
#  estimated_numbers  :integer          default(0)
#  fire_pit           :boolean          default(TRUE)
#  marquee_co         :string(50)
#  marquee_sizes      :string(255)
#  marquees           :integer          default(0)
#  number_of_vehicles :integer          default(0)
#  onsite             :boolean          default(TRUE)
#  service_pref_sat   :string(20)       default("No preference")
#  service_pref_sun   :string(20)       default("No preference")
#  tents              :integer          default(0)
#  updated_by         :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  group_id           :bigint
#
# Indexes
#
#  index_event_details_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
require "test_helper"

class EventDetailTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @event_detail = FactoryBot.create(:event_detail)
  end

  test "should import event details from file" do
    group = FactoryBot.create(:group, abbr: 'CAF')
    file = fixture_file_upload('event_detail.csv','application/csv')
    
    assert_no_difference('EventDetail.count') do
      @result = EventDetail.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting event details from file" do
    group = FactoryBot.create(:group, abbr: 'CAF')
    FactoryBot.create(:event_detail, 
      group: group,
      estimated_numbers: 20)
    
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

  test "should not import event details with errors from file" do
    group = FactoryBot.create(:group, abbr: 'CAF')
    file = fixture_file_upload('invalid_event_detail.csv','application/csv')
    
    assert_no_difference('EventDetail.count') do
      @result = EventDetail.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
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

    event_detail.reload
    assert_not_equal "Not for us", event_detail.buddy_interest
  end
end
