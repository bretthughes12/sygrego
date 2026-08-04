class Api::V1::ParticipantSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :mobile_phone_number, :status, :created_at, :updated_at
end