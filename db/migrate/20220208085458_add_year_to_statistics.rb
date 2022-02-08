class AddYearToStatistics < ActiveRecord::Migration[7.0]
  def change
    add_column :statistics, :year, :integer, default: 2022
  end
end
