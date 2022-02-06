# == Schema Information
#
# Table name: sessions
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  active         :boolean          default("true")
#  database_rowid :integer
#  updated_by     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_sessions_on_database_rowid  (database_rowid) UNIQUE
#  index_sessions_on_name            (name) UNIQUE
#

require "test_helper"

class SessionTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @session = FactoryBot.create(:session, database_rowid: 0)
  end

  test "should compare sport sessions" do
    #comparison against self
    assert_equal 0, @session <=> @session 
    #different rowid
    other_session = FactoryBot.create(:session)
    assert_equal -1, @session <=> other_session
  end

  test "should show only one session name for single session" do 
    assert_equal [@session.name], Session.session_names
  end

  test "should show two session names for two sessions" do
    other_session = FactoryBot.create(:session)

    assert_equal [@session.name, other_session.name], Session.session_names
  end
  
  test "should show the session count" do
    assert_equal 1, Session.total_sessions
  end

  test "should import sessions from file" do
    file = fixture_file_upload('session.csv','application/csv')
    
    assert_difference('Session.count') do
      @result = Session.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting sessions from file" do
    session = FactoryBot.create(:session, database_rowid: 1)
    file = fixture_file_upload('session.csv','application/csv')
    
    assert_no_difference('Session.count') do
      @result = Session.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    session.reload
    assert_equal "The Only Session", session.name
  end

  test "should not import sessions with errors from file" do
    file = fixture_file_upload('invalid_session.csv','application/csv')
    
    assert_no_difference('Session.count') do
      @result = Session.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update sessions with errors from file" do
    session = FactoryBot.create(:session, database_rowid: 1)
    file = fixture_file_upload('invalid_session.csv','application/csv')
    
    assert_no_difference('Session.count') do
      @result = Session.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    session.reload
    assert_not_equal "This Session Name is too long...................................................................", session.name
  end
end
