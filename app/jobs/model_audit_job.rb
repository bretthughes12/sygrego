class ModelAuditJob < ApplicationJob
  queue_as :default

  def perform(record, event, user_id = 1)
    AuditTrail.create(record_id: record.id,
      record_type: record.class.name,
      event: event,
      user_id: user_id)
    end
end
