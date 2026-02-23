class PaymentMailer < ApplicationMailer
    def receipt(payment)
        @payment = payment

        mail(to:      @payment.group.email_recipients,
             bcc:     @settings.admin_email,
             subject: "#{APP_CONFIG[:email_subject]} SYG Payment Receipt")
    end
end
  