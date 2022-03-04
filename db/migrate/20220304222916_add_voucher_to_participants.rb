class AddVoucherToParticipants < ActiveRecord::Migration[7.0]
  def change
    add_reference :participants, :voucher
  end
end
