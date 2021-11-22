class Admin::RegoChecklistsController < ApplicationController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
    
    layout "admin"
  
    # GET /admin/rego_checklists
    def index
      @rego_checklists = RegoChecklist.includes(:group).all.order("groups.abbr").load
  
      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "rego_checklist", "rego_checklist" }
      end
    end

    # GET /admin/rego_checklists/search
    def search
      @groups = Group.search(params[:search]).order("abbr")
      @rego_checklists = @groups.collect(&:rego_checklist)
  
      respond_to do |format|
        format.html { render action: 'index' }
      end
    end

    # GET /admin/rego_checklists/1
    def show
    end
  
    # GET /admin/rego_checklists/1/edit
    def edit
    end
  
    # PUT /admin/rego_checklists/1
    def update
      respond_to do |format|
        if @rego_checklist.update(rego_checklist_params)
          flash[:notice] = 'Checklist was successfully updated.'
          format.html { redirect_to admin_rego_checklists_url }
        else
          format.html { render action: "edit" }
        end
      end
    end

    private
  
    def rego_checklist_params
      params.require(:rego_checklist).permit(:registered, 
                                    :rego_rep,
                                    :rego_mobile,
                                    :admin_rep,
                                    :second_rep,
                                    :second_mobile,
                                    :disabled_participants,
                                    :disabled_notes,
                                    :driver_form,
                                    :finance_notes,
                                    :sport_notes
                                )
    end
end
