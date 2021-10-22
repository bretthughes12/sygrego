class CreateRolesUsers < ActiveRecord::Migration[6.1]
  def self.up 
    create_table :roles_users, :id => false do | t | 
      t.references :role, :user, foreign_key: true
    end 
  end 

  def self.down 
    drop_table :roles_users 
  end 
end
