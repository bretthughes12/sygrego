require "test_helper"

class RoundRobinMatchMailerTest < ActionMailer::TestCase
    tests RoundRobinMatchMailer
  
    def setup
      @admin_role = FactoryBot.create(:role, name: 'admin')
      @user = FactoryBot.create(:user)
      @setting = FactoryBot.create(:setting)
      @section = FactoryBot.create(:section)
    end
    
    def test_sport_coordinator_email
      entry1 = FactoryBot.create(:sport_entry, section: @section)
      entry2 = FactoryBot.create(:sport_entry, section: @section)
      entry3 = FactoryBot.create(:sport_entry, section: @section)
      entry4 = FactoryBot.create(:sport_entry, section: @section)
      match1 = FactoryBot.create(:round_robin_match, 
        :a_wins,
        section: @section,
        match: 1,
        entry_a_id: entry1.id,
        entry_b_id: entry2.id
      )
      match2 = FactoryBot.create(:round_robin_match, 
        :b_wins,
        section: @section,
        match: 3,
        entry_a_id: entry3.id,
        entry_b_id: entry4.id
      )
      match3 = FactoryBot.create(:round_robin_match, 
        :draw,
        section: @section,
        match: 3,
        entry_a_id: entry1.id,
        entry_b_id: entry4.id
      )
      match4 = FactoryBot.create(:round_robin_match, 
        :a_forfeits,
        section: @section,
        match: 4,
        entry_a_id: entry2.id,
        entry_b_id: entry3.id
      )
      match5 = FactoryBot.create(:round_robin_match, 
        :b_forfeits,
        section: @section,
        match: 5,
        entry_a_id: entry1.id,
        entry_b_id: entry3.id
      )
      match6 = FactoryBot.create(:round_robin_match, 
        :both_forfeit,
        section: @section,
        match: 6,
        entry_a_id: entry2.id,
        entry_b_id: entry4.id
      )
      gf = FactoryBot.create(:round_robin_match, 
        :a_wins,
        section: @section,
        match: 200,
        entry_a_id: entry1.id,
        entry_b_id: entry4.id
      )
      
      email = RoundRobinMatchMailer.draw_submitted(@section)
      
      assert_match /Results submitted/, email.subject  
      assert_equal 'sygresults@gmail.com', email.to[0]
      assert_match /Sports results have been submitted/, email.parts[0].body.to_s
    end
  end
