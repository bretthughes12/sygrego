class Admin::InfoController < ApplicationController
    before_action :authenticate_user!, except: [:knockout_reference, :ladder_reference]

    layout 'admin' 

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
        @tech_stats << model_stats(Session)    
        @tech_stats << model_stats(Venue)    
        @tech_stats << model_stats(Volunteer)    
        @tech_stats << model_stats(VolunteerType)    

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

    # GET /admin/info/event_stats
    def event_stats
        @event_stats = Statistic.order(year: :desc, weeks_to_syg: :desc).load

        respond_to do |format|
            format.html { render layout: 'admin' }
        end
    end

    # GET /admin/info/knockout_reference
    def knockout_reference
        redirect_to rails_blob_path(@settings.knockout_reference)
    end

    # GET /admin/info/ladder_reference
    def ladder_reference
        redirect_to rails_blob_path(@settings.ladder_reference)
    end

    private

    def model_stats(model)
        { type: model.name,
          low: model.count > 0 ? model.order(:id).minimum(:id) : 0,
          high: model.count > 0 ? model.order(:id).maximum(:id) : 0 }
    end
end
