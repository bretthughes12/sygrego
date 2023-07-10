class Sc::IncidentReportsController < ScController

  load_and_authorize_resource
  layout 'sc'
  
  # GET /sc/incident_reports/new
  def new
    @incident_report = IncidentReport.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST sc/incident_reports
  def create
    @incident_report = IncidentReport.new(incident_report_params)

    respond_to do |format|
      if @incident_report.save
          flash[:notice] = 'Thanks for reporting. Another?'
          format.html do
            redirect_to new_sc_incident_report_url
          end
      else
          format.html { render action: "new" }
      end
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