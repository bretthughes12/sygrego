class PaymentMailer < ApplicationMailer
    def receipt(payment)
        @payment = payment

        unless @payment.group.email_recipients.nil?
            mail(to:      @payment.group.email_recipients,
                subject: "#{APP_CONFIG[:email_subject]} SYG Payment Receipt")
        end
    end

    def invoice(invoice)
        @invoice = invoice

        unless @invoice.group.email_recipients.nil?
            mail(to:      @invoice.group.email_recipients,
                subject: "#{APP_CONFIG[:email_subject]} New SYG Invoice")
        end
    end
end
  