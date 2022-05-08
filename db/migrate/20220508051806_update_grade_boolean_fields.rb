class UpdateGradeBooleanFields < ActiveRecord::Migration[7.0]
  def change
    change_column :grades, :over_limit, :boolean, default: false
    change_column :grades, :one_entry_per_group, :boolean, default: false
  end
end
