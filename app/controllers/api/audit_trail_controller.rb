class Api::AuditTrailController < ApplicationController
  before_action :authorize_xml
  before_action :authenticate_user!

  # GET /api/audit_trail.xml?start=0&limit=20
  def index
    limit = params[:limit] || 20
    start = params[:start] || 0
      
    @audits = AuditTrail.where(['id > ?', start]).order(:id).limit(limit).load
  
    respond_to do |format|
      format.xml  { render xml: @audits }
    end
  end
end
