class PaymentMailer < ApplicationMailer
    def receipt(payment)
        @payment = payment

        if @settings.send_emails
            mail(to:      @payment.group.email_recipients,
                subject: "#{APP_CONFIG[:email_subject]} SYG Payment Receipt")
        end
    end

    def invoice(invoice)
        @invoice = invoice

        if @settings.send_emails
            mail(to:      @invoice.group.email_recipients,
                subject: "#{APP_CONFIG[:email_subject]} New SYG Invoice")
        end
    end
end
  