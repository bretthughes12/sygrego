# == Schema Information
#
# Table name: participants_users
#
#  participant_id :integer          not null
#  user_id        :integer          not null
#
# Indexes
#
#  index_participants_users_on_participant_id  (participant_id)
#  index_participants_users_on_user_id         (user_id)
#

class ParticipantsUser < ApplicationRecord
    belongs_to :user
    belongs_to :participant
end
