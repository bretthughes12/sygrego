class PaymentMailer < ApplicationMailer
    def receipt(payment)
        @payment = payment

        mail(to:      @payment.group.email_recipients,
             bcc:     @settings.admin_email,
             subject: "#{APP_CONFIG[:email_subject]} SYG Payment Receipt")
    end

    def invoice(invoice)
        @invoice = invoice

        mail(to:      @invoice.group.email_recipients,
             subject: "#{APP_CONFIG[:email_subject]} New SYG Invoice")
    end
end
  