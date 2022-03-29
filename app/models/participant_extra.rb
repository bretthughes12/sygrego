# == Schema Information
#
# Table name: participant_extras
#
#  id             :bigint           not null, primary key
#  comment        :string(255)
#  size           :string(10)
#  wanted         :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_extra_id :bigint           not null
#  participant_id :bigint           not null
#
# Indexes
#
#  index_participant_extras_on_group_extra_id  (group_extra_id)
#  index_participant_extras_on_participant_id  (participant_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_extra_id => group_extras.id)
#  fk_rails_...  (participant_id => participants.id)
#
class ParticipantExtra < ApplicationRecord
  belongs_to :participant
  belongs_to :group_extra

  SIZES = %w[XS S M L
    XL XXL XXXL].freeze

  validates :size,
    length: { maximum: 10 },
    inclusion: { in: SIZES },
    allow_blank: true
  validates :comment,
    allow_blank: true,
    length: { maximum: 255 }

  delegate :name, to: :group_extra
  delegate :needs_size, to: :group_extra
  delegate :cost, to: :group_extra
  delegate :show_comment, to: :group_extra
  delegate :comment_prompt, to: :group_extra

  scope :wanted, -> { where(wanted: true) }

  def self.initialise_for_participant(participant)
    extras = []

    unless participant.nil?
      extras = participant.group_extras.collect do |group_extra|
        ParticipantExtra.find_or_create_by(participant_id: participant.id, group_extra_id: group_extra.id) do |extra|
          extra.participant_id = participant.id
          extra.group_extra_id = group_extra.id
          extra.wanted = !group_extra.optional
        end
      end
    end

    extras
  end
end
