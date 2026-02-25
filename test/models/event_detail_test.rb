# == Schema Information
#
# Table name: event_details
#
#  id                    :bigint           not null, primary key
#  buddy_comments        :text
#  buddy_interest        :string(50)
#  camping_rqmts         :text
#  caravans              :integer          default(0)
#  estimated_numbers     :integer          default(0)
#  fire_pit              :boolean          default(TRUE)
#  marquee_co            :string(50)
#  marquee_sizes         :string(255)
#  marquees              :integer          default(0)
#  number_of_vehicles    :integer          default(0)
#  onsite                :boolean          default(TRUE)
#  orientation_details   :string(100)
#  service_pref_fri      :string(20)       default("No preference")
#  service_pref_sat      :string(20)       default("No preference")
#  service_pref_sun      :string(20)       default("No preference")
#  tents                 :integer          default(0)
#  updated_by            :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  group_id              :bigint
#  orientation_detail_id :bigint
#  warden_zone_id        :bigint
#
# Indexes
#
#  index_event_details_on_group_id               (group_id)
#  index_event_details_on_orientation_detail_id  (orientation_detail_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (orientation_detail_id => orientation_details.id)
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
    
    file = fixture_file_upload('event_detail.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('EventDetail.count') do
      @result = EventDetail.import_excel(file, @user)
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
    file = fixture_file_upload('invalid_event_detail.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('EventDetail.count') do
      @result = EventDetail.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    group.reload
    group.event_detail.reload
    assert_not_equal "Not for us", group.event_detail.buddy_interest
  end
end
