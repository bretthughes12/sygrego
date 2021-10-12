class AddGroupsUsers < ActiveRecord::Migration[6.1]
  def self.up 
    create_table :groups_users, :id => false do | t | 
      t.references :group, :user, foreign_key: true
    end 
  end 

  def self.down 
    drop_table :groups_users 
  end 
end
