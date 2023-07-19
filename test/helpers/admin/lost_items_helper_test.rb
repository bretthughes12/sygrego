require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/lost_item_helper'

class Admin::LostItemsHelperTest < ActionView::TestCase
  include Admin::LostItemHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @settings = FactoryBot.create(:setting)
    @item = FactoryBot.create(:lost_item)
  end
  
  test "lost item display classes" do
    assert_equal "table-secondary", item_display_class(@item)

    claimed = FactoryBot.create(:lost_item, :claimed)
    assert_equal "table-primary", item_display_class(claimed)
  end
  
  test "whether lost property can be shown" do
    assert_equal false, show_lost_property

    @settings.syg_is_finished = true
    @settings.save
    assert_equal true, show_lost_property
  end
end