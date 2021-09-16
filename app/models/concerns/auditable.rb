module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_create
    before_update :log_update
    before_destroy :log_destroy
  end

  private

  def log_create
    user_id = self.respond_to?(:updated_by) ? self.updated_by : User.first.id
    ModelAuditJob.perform_later(self, 'CREATE', user_id)
  end

  def log_update
    if sync_fields_updated?
      user_id = self.respond_to?(:updated_by) ? self.updated_by : User.first.id
      ModelAuditJob.perform_later(self, 'UPDATE', user_id)
    end
  end

  def log_destroy
    user_id = self.respond_to?(:updated_by) ? self.updated_by : User.first.id
    ModelAuditJob.perform_now(self, 'DESTROY', user_id)
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