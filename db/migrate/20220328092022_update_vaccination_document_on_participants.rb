class UpdateVaccinationDocumentOnParticipants < ActiveRecord::Migration[7.0]
  def change
    change_column :participants, :vaccination_document, :string, limit: 40
  end
end
