class VolunteerMailer < ActionMailer::Base
    default from: 'sportadmin@stateyouthgames.com',
            cc:   'registrations@stateyouthgames.com'
#            cc:   ['sports@stateyouthgames.com', 'sportadmin@stateyouthgames.com', 'registrations@stateyouthgames.com']
    layout 'mailer'
    before_action :get_settings
    
    def welcome(volunteer)
      @sport = volunteer.sport
      @section = volunteer.section
      
      unless volunteer.sport.nil?
#        map_type = DownloadType.find_by_name("Maps - Sports Venues")
#        @maps = map_type.downloads if map_type
        @maps = nil
#        info_type = DownloadType.find_by_name("Sports Information & Rules Booklet")
#        @info = info_type.downloads if info_type
        @info = nil
#        @rules = @sport.downloads
        
#        case
#          when @sport.draw_type == "Round Robin"
#            how_to_type = DownloadType.find_by_name("Sports Officials - How to Complete the Ladder Worksheet")
#            @how_tos = how_to_type.downloads if how_to_type
        
#          when @sport.draw_type == "Knockout"
#            how_to_type = DownloadType.find_by_name("Sports Officials - How to Complete a Knockout")
#            @how_tos = how_to_type.downloads if how_to_type
#        end
        
      end
  
      mail(to:      volunteer.email_recipients, 
           subject: "#{APP_CONFIG[:email_subject]} SYG #{APP_CONFIG[:this_year]} - Welcome Sports Coordinators")
    end

    private

    def get_settings
        @settings ||= Setting.first
    end
end
  