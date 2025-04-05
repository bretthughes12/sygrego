module Admin::PaymentsHelper
    def payment_display_class(payment)
        case
        when payment.reconciled
            "table-primary"
        when payment.paid
            "table-warning"
        else
            "table-dark"
        end
    end
end
