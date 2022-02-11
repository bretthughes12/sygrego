# == Schema Information
#
# Table name: volunteers
#
#  id                :bigint           not null, primary key
#  collected         :boolean          default(FALSE)
#  description       :string(100)      not null
#  details_confirmed :boolean          default(FALSE)
#  email             :string(40)
#  equipment_in      :string
#  equipment_out     :string
#  lock_version      :integer          default(0)
#  mobile_confirmed  :boolean          default(FALSE)
#  mobile_number     :string(20)
#  notes             :text
#  returned          :boolean          default(FALSE)
#  t_shirt_size      :string(10)
#  updated_by        :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  participant_id    :bigint
#  section_id        :bigint
#  session_id        :bigint
#  volunteer_type_id :bigint
#
# Indexes
#
#  index_volunteers_on_participant_id     (participant_id)
#  index_volunteers_on_volunteer_type_id  (volunteer_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (volunteer_type_id => volunteer_types.id)
#
class Volunteer < ApplicationRecord
end
