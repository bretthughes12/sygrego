module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_create
    after_update :log_update
    before_destroy :log_destroy
  end

  private

  def log_create
    user_id = self.respond_to?(:updated_by) ? self.updated_by : nil
    ModelAuditJob.perform_later(self, 'CREATE', user_id)
  end

  def log_update
    user_id = self.respond_to?(:updated_by) ? self.updated_by : nil
    ModelAuditJob.perform_later(self, 'UPDATE', user_id)
  end

  def log_destroy
    user_id = self.respond_to?(:updated_by) ? self.updated_by : nil
    ModelAuditJob.perform_now(self, 'DESTROY', user_id)
  end
end