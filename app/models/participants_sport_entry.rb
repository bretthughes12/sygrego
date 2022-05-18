# == Schema Information
#
# Table name: participants_sport_entries
#
#  participant_id :bigint           not null
#  sport_entry_id :bigint           not null
#

class ParticipantsSportEntry < ApplicationRecord
    include Auditable

    belongs_to :participant
    belongs_to :sport_entry
end
  
