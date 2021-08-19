module Auditable
    extend ActiveSupport::Concern

    included do
        after_create :log_create
        after_update :log_update
        before_destroy :log_destroy
    end

    def log(record, event, user_id = 1)
        AuditTrail.create(record_id: record.id,
                          record_type: record.class.name,
                          event: event,
                          user_id: user_id)
    end

    private

    def log_create
        log(self, 'CREATE')
    end

    def log_update
        log(self, 'UPDATE')
    end

    def log_destroy
        log(self, 'DESTROY')
    end
end