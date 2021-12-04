class Admin::InfoController < ApplicationController
    before_action :authenticate_user!

    layout 'admin'

    # GET /admin/info/home
    def home
        @total_groups = Group.coming.count
        new_groups = Group.coming.not_admin.new_group.count
        last_year_groups = Group.coming.not_admin.last_year.count
        admin_groups = Group.coming.is_admin.count
        @total_participants = Participant.accepted.coming.count

        @groups_data = []
        @groups_data << ChartData.new("New groups", new_groups)
        @groups_data << ChartData.new("Came " + (@settings.this_year - 1).to_s, last_year_groups)
        @groups_data << ChartData.new("Came pre-" + (@settings.this_year - 1).to_s, @total_groups - new_groups - last_year_groups - admin_groups)
        @groups_data << ChartData.new("Admin", admin_groups)
    
        @participants_data = []
        @participants_data << ChartData.new("Spectators", Participant.coming.accepted.spectators.count)
        @participants_data << ChartData.new("Playing", Participant.coming.accepted.playing_sport.count)
        @participants_data << ChartData.new("Not Approved", Participant.coming.requiring_approval.count)
    end

    # GET /admin/info/tech_stats
    def tech_stats
        @tech_stats = []

        @tech_stats << model_stats(Group)    
        @tech_stats << model_stats(EventDetail)    
        @tech_stats << model_stats(Participant)    
        @tech_stats << model_stats(Sport)    
        @tech_stats << model_stats(Grade) 
        @tech_stats << model_stats(Section)    
        @tech_stats << model_stats(Session)    
        @tech_stats << model_stats(Venue)    

        @tech_stats << { type: "AuditTrail", 
                         low: "-",
                         high: AuditTrail.order(:id).last.id }    

        @queue_stats = []

        @queue_stats << { type: "Jobs Queued", 
                          stat: Delayed::Job.count }    

        @queue_stats << { type: "Jobs Locked", 
                          stat: Delayed::Job.where('locked_at is not null').count }    

        @queue_stats << { type: "Jobs Failed", 
                          stat: Delayed::Job.where('failed_at is not null').count }    

        respond_to do |format|
            format.html { render layout: 'admin' }
        end
    end

    private

    def model_stats(model)
        { type: model.name,
          low: model.count > 0 ? model.order(:id).minimum(:id) : 0,
          high: model.count > 0 ? model.order(:id).maximum(:id) : 0 }
    end
end
