require "test_helper"

class TasksMailerTest < ActionMailer::TestCase
    tests TasksMailer
  
    def setup
      @admin_role = FactoryBot.create(:role, name: 'admin')
      @user = FactoryBot.create(:user)
      @setting = FactoryBot.create(:setting)
    end
    
    test "should send an allocations done email" do
      email = TasksMailer.allocations_done
      
      assert_match /Restricted Sports Allocation/, email.subject  
      assert_equal @setting.rego_email, email.to[0]
      assert_match /allocation has completed/, email.parts[0].body.to_s
    end
    
    test "should send a grades finalised email" do
      email = TasksMailer.grades_finalised
      
      assert_match /Grades Finalised/, email.subject  
      assert_equal @setting.rego_email, email.to[0]
      assert_match /ready for Sports Draws/, email.parts[0].body.to_s
    end
  end
