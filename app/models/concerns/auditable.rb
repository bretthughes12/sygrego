module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_create
    before_update :log_update
    before_destroy :log_destroy
  end

  private

# TODO: remove hard-coding for ParticipantsSportEntry and 
#       handle this using metadata from the model

  def log_create
    if self.class.name == 'ParticipantsSportEntry'
      model = self.sport_entry
      action = 'UPDATE'
    else
      model = self
      action = 'CREATE'
    end

    ModelAuditJob.perform_now(model, action, audit_user_id)
  end

  def log_update
    if sync_fields_updated?
      ModelAuditJob.perform_now(self, 'UPDATE', audit_user_id)
    end
  end

  def log_destroy
    if self.class.name == 'ParticipantsSportEntry'
      model = self.sport_entry
      action = 'UPDATE'
    else
      model = self
      action = 'DESTROY'
    end

    ModelAuditJob.perform_now(model, action, audit_user_id)
  end

  def audit_user_id
    if self.respond_to?(:updated_by) 
      self.updated_by.nil? ? User.first.id : self.updated_by
    else
      User.first.id
    end
  end

  def sync_fields_updated?
    if self.class.respond_to?(:sync_fields)
      self.class.sync_fields.each do |field|
        return true if self.send("#{field}_changed?")
      end
      return false
    else
      true
    end
  end
end