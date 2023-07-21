class RoundRobinMatchMailer < ApplicationMailer
    default from: 'registrations@stateyouthgames.com',
            to:    'sygresults@gmail.com',
            cc:    'registrations@stateyouthgames.com'
  
    def draw_submitted(section)
      @section = section
      @results = @section.round_robin_matches.order(:match)
  
      mail(subject: "#{APP_CONFIG[:email_subject]} Results submitted online for #{@section.name}")
    end
end
  