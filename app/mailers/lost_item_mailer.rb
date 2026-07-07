class LostItemMailer < ApplicationMailer
    def claimed_item(item)
        @item = item

        if @settings.send_emails
        mail(to:      @settings.lost_property_email,
                 subject: "#{APP_CONFIG[:email_subject]} Claimed lost property notification")
        end
    end
end