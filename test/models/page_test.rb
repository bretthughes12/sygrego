# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  name       :string(50)
#  permalink  :string(20)
#  admin_use  :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pages_on_name       (name) UNIQUE
#  index_pages_on_permalink  (permalink) UNIQUE
#

require "test_helper"

class PageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
