class SportResultMailer < ActionMailer::Base
    default from: 'registrations@stateyouthgames.com',
            to:    'sygresults.gmail.com',
            cc:    'registrations@stateyouthgames.com'
    layout 'mailer'
    before_action :get_settings
  
    def draw_submitted(section)
      @section = section
  
      mail(subject: "#{APP_CONFIG[:email_subject]} Results submitted online for #{@section.name}")
    end

    private

    def get_settings
        @settings ||= Setting.first
    end
end
  