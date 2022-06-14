class AddNotesToLostItems < ActiveRecord::Migration[7.0]
  def change
    add_column :lost_items, :notes, :text
  end
end
