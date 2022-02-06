# == Schema Information
#
# Table name: participants_sport_entries
#
#  participant_id :integer          not null
#  sport_entry_id :integer          not null
#

class ParticipantsSportEntry < ActiveRecord::Base
    belongs_to :participant
    belongs_to :sport_entry
end
  
