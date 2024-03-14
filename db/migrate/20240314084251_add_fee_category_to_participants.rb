class AddFeeCategoryToParticipants < ActiveRecord::Migration[7.1]
  def change
    add_reference :participants, :group_fee_category
  end
end
