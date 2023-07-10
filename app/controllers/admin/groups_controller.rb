class Admin::GroupsController < AdminController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
    
    # GET /admin/groups
    def index
      @groups = Group.order(:abbr).load
  
      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "group", "group" }
      end
    end

    # GET /admin/groups/approvals
    def approvals
      @groups = Group.not_stale.order(:abbr).load
  
      respond_to do |format|
        format.html # approvals.html.erb
        format.csv  { render_csv "submissions", "submissions" }
      end
    end

    # GET /admin/groups/session_participants
    def session_participants
      @groups = Group.not_admin.coming.order(:abbr).load
  
      respond_to do |format|
        format.html # approvals.html.erb
        format.csv  { render_csv "participant_audit", "participant_audit" }
      end
    end

    # GET /admin/groups/summary
    def summary
      @groups = Group.coming.order(:name).load

      respond_to do |format|
        format.html # approvals.html.erb
        format.csv  { render_csv "group_summary", "group_summary" }
      end
    end

    # GET /admin/groups/payments
    def payments
      @groups = Group.coming.not_admin.order(:name).load

      respond_to do |format|
        format.html # payments.html.erb
      end
    end

    # GET /admin/groups/sport_summary
    def sport_summary
      @groups = Group.coming.not_admin.order(:name).load

      respond_to do |format|
        format.html # sport_summary.html.erb
      end
    end

    # GET /admin/groups/search
    def search
      @groups = Group.search(params[:search]).order("abbr")
  
      respond_to do |format|
        format.html { render action: 'index' }
      end
    end
    
    # GET /admin/groups/1
    def show
    end
  
    # GET /admin/groups/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/groups/1/edit
    def edit
    end
  
    # POST /admin/groups
    def create
        @group = Group.new(group_params)
        @group.updated_by = current_user.id

        respond_to do |format|
            if @group.save
                flash[:notice] = 'Group was successfully created.'
                format.html { render action: "edit" }
            else
                format.html { render action: "new" }
            end
        end
    end
  
    # PATCH /admin/groups/1
    def update
      @group.updated_by = current_user.id

      respond_to do |format|
        if @group.update(group_params)
          flash[:notice] = 'Group was successfully updated.'
          format.html { redirect_to admin_groups_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # POST /admin/groups/1/invoice
    def invoice
      @payments = @group.payments.
        order(:paid_at).load

      respond_to do |format|
        format.pdf  do
          output = TaxInvoice.new.add_data(@group, @payments).to_pdf
          
          render_pdf output, 'tax-invoice'
        end
      end
    end
  
    # PATCH /admin/groups/1/approve
    def approve
      @group.updated_by = current_user.id
      @group.status = "Approved"
      @group.save

      @group.users.not_stale.each do |u|
        u.status = "Verified"
        u.save(validate: false)
        
        UserMailer.gc_approval(u).deliver_now if u.role?(:gc) || u.role?(:church_rep)
      end

      flash[:notice] = 'Group approved'
      redirect_to approvals_admin_groups_url
    end
  
    # DELETE /admin/groups/1
    def destroy
      @group.updated_by = current_user.id

      @group.destroy

      respond_to do |format|
          format.html { redirect_to admin_groups_url }
      end
    end
  
    # GET /admin/groups/new_import
    def new_import
      @group = Group.new
    end
  
    # POST /admin/groups/import
    def import
      if params[:group] && params[:group][:file].path =~ %r{\.csv$}i
        result = Group.import(params[:group][:file], current_user)

        flash[:notice] = "Groups upload complete: #{result[:creates]} groups created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_groups_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
        @group = Group.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end
  
    # PATCH /admin/user/1/groups/add_group
    def add_group
      @user = User.find(params[:user_id])
      @group = Group.find(params[:group_id])

      @user.groups << @group unless @user.groups.include?(@group)

      respond_to do |format|
        format.html { redirect_to edit_admin_user_url(@user) }
      end
    end
  
    # DELETE /admin/user/1/group/1/purge
    def purge
      @user = User.find(params[:user_id])

      @user.groups.delete(@group)
  
      respond_to do |format|
        format.html { redirect_to edit_admin_user_url(@user) }
      end
    end

private
  
    def group_params
      params.require(:group).permit(:abbr, 
                                    :name, 
                                    :short_name,
                                    :coming,
                                    :lock_version,
                                    :new_group,
                                    :trading_name,
                                    :address,
                                    :suburb,
                                    :postcode,
                                    :phone_number,
                                    :last_year,
                                    :ticket_preference,
                                    :ticket_email,
                                    :admin_use,
                                    :late_fees,
                                    :email,
                                    :website,
                                    :denomination,
                                    :years_attended,
                                    :status,
                                    :age_demographic,
                                    :group_focus
                                )
    end
end
