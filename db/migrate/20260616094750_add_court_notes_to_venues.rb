class AddCourtNotesToVenues < ActiveRecord::Migration[8.1]
  def change
    add_column :venues, :court_notes, :text
  end
end
