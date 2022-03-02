module Admin::PaymentsHelper
    def payment_display_class(payment)
        case
        when payment.reconciled
            "table-primary"
        else
            "table-warning"
        end
    end
end
