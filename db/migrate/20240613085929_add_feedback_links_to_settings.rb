class AddFeedbackLinksToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :gc_feedback_url, :string
    add_column :settings, :participant_feedback_url, :string
  end
end
