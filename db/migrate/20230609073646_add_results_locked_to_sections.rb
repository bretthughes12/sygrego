class AddResultsLockedToSections < ActiveRecord::Migration[7.0]
  def change
    add_column :sections, :results_locked, :boolean, default: false
  end
end
