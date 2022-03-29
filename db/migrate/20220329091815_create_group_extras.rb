class CreateGroupExtras < ActiveRecord::Migration[7.0]
  def change
    create_table :group_extras do |t|
      t.references :group, null: false, foreign_key: true
      t.string :name, limit: 20, null: false
      t.boolean :needs_size, default: false
      t.decimal :cost, precision: 8, scale: 2
      t.boolean :optional, default: true
      t.boolean :show_comment, default: false
      t.string :comment_prompt

      t.timestamps
    end
  end
end
