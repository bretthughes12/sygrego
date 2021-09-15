class RemoveLockVersionFromSports < ActiveRecord::Migration[6.1]
  def change
    remove_column :sports, :lock_version
  end
end
