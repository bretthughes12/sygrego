# == Schema Information
#
# Table name: pages
#
#  id         :bigint           not null, primary key
#  admin_use  :boolean
#  name       :string(50)
#  permalink  :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pages_on_name       (name) UNIQUE
#  index_pages_on_permalink  (permalink) UNIQUE
#
class Page < ActiveRecord::Base
  
    has_rich_text :content

    scope :public_viewable, -> { where(admin_use: false) }
  
    validates :name,                   presence: true,
                                       length: { maximum: 50 }
    validates :permalink,              presence: true,
                                       uniqueness: { case_sensitive: false },
                                       length: { maximum: 20 }
  
  end
