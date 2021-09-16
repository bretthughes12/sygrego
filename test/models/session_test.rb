# == Schema Information
#
# Table name: sessions
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(TRUE)
#  database_rowid :integer
#  name           :string           not null
#  updated_by     :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require "test_helper"

class SessionTest < ActiveSupport::TestCase
  def setup
    FactoryBot.create(:user)
    @session = FactoryBot.create(:session)
  end

  test "should compare sport sessions" do
    #comparison against self
    assert_equal 0, @session <=> @session 
    #different rowid
    other_session = FactoryBot.create(:session)
    assert_equal -1, @session <=> other_session
  end

  def test_session_names_for_single_session
    assert_equal [@session.name], Session.session_names
  end

  def test_session_names_for_two_sessions
    other_session = FactoryBot.create(:session)

    assert_equal [@session.name, other_session.name], Session.session_names
  end
  
  def test_session_count
    assert_equal 1, Session.total_sessions
  end
end
