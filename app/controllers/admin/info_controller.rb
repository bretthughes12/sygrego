class Admin::InfoController < AdminController
    before_action :authenticate_user!

    # GET /admin/info/home
    def home
        @total_groups = Group.coming.count
        @total_participants = Participant.accepted.coming.count
        @total_entries = SportEntry.count
        @total_volunteers = Volunteer.count
    end

    # GET /admin/info/tech_stats
    def tech_stats
        @tech_stats = []

        @tech_stats << model_stats(Group)    
        @tech_stats << model_stats(EventDetail)    
        @tech_stats << model_stats(Participant)    
        @tech_stats << model_stats(SportEntry)    
        @tech_stats << model_stats(Sport)    
        @tech_stats << model_stats(Grade) 
        @tech_stats << model_stats(Section)    
        @tech_stats << model_stats(RoundRobinMatch)    
        @tech_stats << model_stats(Session)    
        @tech_stats << model_stats(Venue)    
        @tech_stats << model_stats(Volunteer)    
        @tech_stats << model_stats(VolunteerType)    

        @tech_stats << { type: "AuditTrail", 
                         low: "-",
                         high: AuditTrail.order(:id).last.id,
                         count: AuditTrail.count }    

        @other_stats = []

        @other_stats << model_stats(User)    
        @other_stats << model_stats(MysygSetting)    
        @other_stats << model_stats(RegoChecklist)    
        @other_stats << model_stats(Voucher)    
        @other_stats << model_stats(Payment)    
        @other_stats << model_stats(GroupsGradesFilter)    
        @other_stats << model_stats(SportPreference)    
        @other_stats << model_stats(GroupExtra)    
        @other_stats << model_stats(GroupFeeCategory)    
        @other_stats << model_stats(ParticipantExtra)    
        @other_stats << model_stats(Award)    
        @other_stats << model_stats(SportsEvaluation)    
        @other_stats << model_stats(LostItem)    
                 
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

    # GET /admin/info/event_stats
    def event_stats
        @event_stats = Statistic.order(year: :desc, weeks_to_syg: :desc).load

        respond_to do |format|
            format.html { render layout: 'admin' }
        end
    end

    private

    def model_stats(model)
        { type: model.name,
          low: model.count > 0 ? model.order(:id).minimum(:id) : 0,
          high: model.count > 0 ? model.order(:id).maximum(:id) : 0,
          count: model.count }
    end
end
