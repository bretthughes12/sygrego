# == Schema Information
#
# Table name: participants_users
#
#  participant_id :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_participants_users_on_participant_id  (participant_id)
#  index_participants_users_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (participant_id => participants.id)
#  fk_rails_...  (user_id => users.id)
#

class ParticipantsUser < ApplicationRecord
    belongs_to :user
    belongs_to :participant
end
