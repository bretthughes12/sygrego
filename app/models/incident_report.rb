# == Schema Information
#
# Table name: incident_reports
#
#  id           :bigint           not null, primary key
#  action_taken :text
#  description  :text             not null
#  name         :string(100)      not null
#  other_info   :text
#  section      :string(50)       not null
#  session      :string(50)       not null
#  venue        :string(50)       not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_incident_reports_on_section  (section)
#
class IncidentReport < ApplicationRecord

    validates :name,
        presence: true,
        length: { maximum: 100 }
    validates :section,
        presence: true,
        length: { maximum: 50 }
    validates :session,
        presence: true,
        length: { maximum: 50 }
    validates :venue,
        presence: true,
        length: { maximum: 50 }
    validates :description,
        presence: true

end
