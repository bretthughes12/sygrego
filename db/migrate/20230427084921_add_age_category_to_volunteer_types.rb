class AddAgeCategoryToVolunteerTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :volunteer_types, :age_category, :string, limit: 20, default: "Over 18"
  end
end
