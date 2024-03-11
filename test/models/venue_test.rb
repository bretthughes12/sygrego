# == Schema Information
#
# Table name: venues
#
#  id            :bigint           not null, primary key
#  active        :boolean
#  address       :string
#  database_code :string(4)
#  name          :string(50)       default(""), not null
#  updated_by    :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_venues_on_database_code  (database_code) UNIQUE
#  index_venues_on_name           (name) UNIQUE
#

require "test_helper"

class VenueTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
      FactoryBot.create(:role, name: 'admin')
      @user = FactoryBot.create(:user)
      @venue = FactoryBot.create(:venue, database_code: 'ABC')
  end

  test "should import venues from file" do
    file = fixture_file_upload('venue.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_difference('Venue.count') do
      @result = Venue.import_excel(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting venues from file" do
    venue = FactoryBot.create(:venue, database_code: 'MCG')
    file = fixture_file_upload('venue.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Venue.count') do
      @result = Venue.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    venue.reload
    assert_equal "Melbourne Cricket Ground", venue.name
  end

  test "should not import venues with errors from file" do
    file = fixture_file_upload('invalid_venue.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Venue.count') do
      @result = Venue.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update venues with errors from file" do
    venue = FactoryBot.create(:venue, database_code: 'MCG')
    file = fixture_file_upload('invalid_venue.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Venue.count') do
      @result = Venue.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    venue.reload
    assert_not_equal "This Venue Name is too long...................................................................", venue.name
  end
end
