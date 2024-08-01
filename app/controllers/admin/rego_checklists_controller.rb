class Admin::RegoChecklistsController < AdminController

    load_and_authorize_resource
    before_action :authenticate_user!
    
    # GET /admin/rego_checklists
    def index
      @rego_checklists = RegoChecklist.includes(:group).where("groups.coming = true AND groups.admin_use = false").all.order("groups.abbr").load
  
      respond_to do |format|
        format.html # index.html.erb
        format.xlsx { render xlsx: "index", filename: "rego_checklist.xlsx" }
      end
    end

    # GET /admin/rego_checklists/site_checks
    def site_checks
      @rego_checklists = RegoChecklist.includes(:group).where("groups.coming = true AND groups.admin_use = false").all.order("groups.abbr").load
  
      respond_to do |format|
        format.html # index.html.erb
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
      prepare_for_edit
    end
  
    # GET /admin/rego_checklists/1/edit_site_check
    def edit_site_check
      if @rego_checklist.site_check_completed_by.blank?
        @rego_checklist.site_check_completed_by = current_user.name 
      end
    end
  
    # PATCH /admin/rego_checklists/1
    def update
      respond_to do |format|
        if @rego_checklist.update(rego_checklist_params)
          flash[:notice] = 'Checklist was successfully updated.'
          format.html { redirect_to admin_rego_checklists_url }
        else
          format.html do
            prepare_for_edit
            render action: "edit"
          end
        end
      end
    end

    # PATCH /admin/rego_checklists/1/update_site_check
    def update_site_check
      respond_to do |format|
        @rego_checklist.site_check_completed_at = Time.now

        if @rego_checklist.update(site_checklist_params)
          flash[:notice] = 'Checklist was successfully updated.'
          format.html { redirect_to site_checks_admin_rego_checklists_url }
        else
          format.html do
            render action: "edit_site_check"
          end
        end
      end
    end

    private
  
    def prepare_for_edit
      @group = @rego_checklist.group
      @gc = @group.gcs.first
      if @rego_checklist.rego_mobile.blank? && !@gc.nil?
        @rego_checklist.rego_mobile = @gc.phone_number 
      end
      if @rego_checklist.rego_rep.blank? 
        @rego_checklist.rego_rep = @group.gc_name 
      end
      if @rego_checklist.admin_rep.blank?
        @rego_checklist.admin_rep = current_user.name 
      end

      @sport_coords = @group.sport_coords
    end

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
                                    :sport_notes,
                                    :food_cert_sighted,
                                    :covid_plan_sighted,
                                    :insurance_sighted,
                                    :upload_notes,
                                    :driving_notes,
                                    :site_check_notes
                                )
    end

    def site_checklist_params
      params.require(:rego_checklist).permit(:registered, 
                                    :site_check_church_contact,
                                    :site_check_completed_by,
                                    :site_check_status,
                                    :site_check_electrical_1,
                                    :site_check_electrical_2,
                                    :site_check_electrical_3,
                                    :site_check_electrical_4,
                                    :site_check_electrical_5,
                                    :site_check_electrical_6,
                                    :site_check_electrical_7,
                                    :site_check_electrical_8,
                                    :site_check_fire_1,
                                    :site_check_fire_2,
                                    :site_check_fire_3,
                                    :site_check_fire_4,
                                    :site_check_flames_1,
                                    :site_check_flames_2,
                                    :site_check_flames_3,
                                    :site_check_flames_4,
                                    :site_check_flames_5,
                                    :site_check_flames_6,
                                    :site_check_food_1,
                                    :site_check_food_2,
                                    :site_check_food_3,
                                    :site_check_gas_1,
                                    :site_check_gas_2,
                                    :site_check_medical_1,
                                    :site_check_medical_2,
                                    :site_check_medical_3,
                                    :site_check_medical_4,
                                    :site_check_medical_5,
                                    :site_check_medical_6,
                                    :site_check_safety_1,
                                    :site_check_safety_2,
                                    :site_check_safety_3,
                                    :site_check_safety_4,
                                    :site_check_safety_5,
                                    :site_check_site_1,
                                    :site_check_site_2
                                )
    end
end
