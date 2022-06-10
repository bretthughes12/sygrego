class Admin::IncidentReportsController < ApplicationController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout 'admin'
    
    # GET /admin/incident_reports
    def index
      @incident_reports = IncidentReport.order(:section).load

      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "incident_reports", "incident_reports" }
        format.pdf  # index.pdf.prawn
      end
    end
  
    # GET /admin/incident_reports/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/incident_reports/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/incident_reports/1/edit
    def edit
    end
  
    # POST /admin/incident_reports
    def create
      @incident_report = IncidentReport.new(incident_report_params)

      respond_to do |format|
        if @incident_report.save
          flash[:notice] = 'Report was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/incident_reports/1
    def update
      respond_to do |format|
        if @incident_report.update(incident_report_params)
          flash[:notice] = 'Report was successfully updated.'
          format.html { redirect_to admin_incident_reports_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/incident_reports/1
    def destroy
      flash[:notice] = 'Report deleted.'
      @incident_report.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_incident_reports_url }
      end
    end
  
    private
    
    def incident_report_params
      params.require(:incident_report).permit(
        :section, 
        :session,
        :venue,
        :description,
        :name,
        :action_taken,
        :other_info
      )
    end
end
  