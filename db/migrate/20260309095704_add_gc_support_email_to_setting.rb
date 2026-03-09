class AddGcSupportEmailToSetting < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :gc_support_email, :string, limit: 100, default: ""
  end
end
