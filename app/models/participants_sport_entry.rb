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

    def sync_model
        self.sport_entry
    end

    private

    def self.sync_create_action
        'UPDATE'
    end

    def self.sync_destroy_action
        'UPDATE'
    end
end
  
