module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_create
    after_update :log_update
    before_destroy :log_destroy
  end

  private

  def log_create
    ModelAuditJob.perform_later(self, 'CREATE')
  end

  def log_update
    ModelAuditJob.perform_later(self, 'UPDATE')
  end

  def log_destroy
    ModelAuditJob.perform_now(self, 'DESTROY')
  end
end