# == Schema Information
#
# Table name: volunteer_types
#
#  id            :bigint           not null, primary key
#  active        :boolean          default(TRUE)
#  age_category  :string(20)       default("Over 18")
#  database_code :string(4)
#  description   :text
#  name          :string(100)      not null
#  sport_related :boolean          default(FALSE)
#  t_shirt       :boolean          default(FALSE)
#  updated_by    :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_volunteer_types_on_name  (name) UNIQUE
#

require "test_helper"

class VolunteerTypeTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
      FactoryBot.create(:role, name: 'admin')
      @user = FactoryBot.create(:user)
      @volunteer_type = FactoryBot.create(:volunteer_type, 
        database_code: 'ABC')
  end

  test "should calculate the minimum age" do
    @volunteer_type.age_category = "Over 18"
    assert_equal 18, @volunteer_type.min_age

    @volunteer_type.age_category = "Over 16"
    assert_equal 16, @volunteer_type.min_age
  end

  test "should import volunteer_types from file" do
    file = fixture_file_upload('volunteer_type.csv','application/csv')
    
    assert_difference('VolunteerType.count') do
      @result = VolunteerType.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting volunteer_types from file" do
    volunteer_type = FactoryBot.create(:volunteer_type, name: 'Caffeine Gopher')
    file = fixture_file_upload('volunteer_type.csv','application/csv')
    
    assert_no_difference('VolunteerType.count') do
      @result = VolunteerType.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    volunteer_type.reload
    assert_equal "CAFF", volunteer_type.database_code
  end

  test "should not import volunteer_types with errors from file" do
    file = fixture_file_upload('invalid_volunteer_type.csv','application/csv')
    
    assert_no_difference('VolunteerType.count') do
      @result = VolunteerType.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update volunteer_types with errors from file" do
    volunteer_type = FactoryBot.create(:volunteer_type, name: 'Caffeine Gopher')
    file = fixture_file_upload('invalid_volunteer_type.csv','application/csv')
    
    assert_no_difference('VolunteerType.count') do
      @result = VolunteerType.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    volunteer_type.reload
    assert_not_equal "INVALID", volunteer_type.database_code
  end
end
