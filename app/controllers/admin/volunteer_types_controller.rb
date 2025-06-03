class Admin::VolunteerTypesController < AdminController

    load_and_authorize_resource
    before_action :authenticate_user!
  
    # GET /admin/volunteer_types
    def index
      @volunteer_types = VolunteerType.order("name").all
  
      respond_to do |format|
        format.html {  }
        format.xlsx { render xlsx: "index", filename: "volunteer_types.xlsx" }
      end
    end
  
    # GET /admin/volunteer_types/1
    def show
    end
  
    # GET /admin/volunteer_types/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/volunteer_types/1/edit
    def edit
    end
  
    # POST /admin/volunteer_types
    def create
        @volunteer_type = VolunteerType.new(volunteer_type_params)
        @volunteer_type.updated_by = current_user.id

        respond_to do |format|
            if @volunteer_type.save
                flash[:notice] = 'Volunteer type was successfully created.'
                format.html { render action: "edit" }
            else
                format.html { render action: "new" }
            end
        end
    end
  
    # POST /admin/volunteer_types/1/send_emails
    def send_emails
      emails_sent = 0

      @volunteer_type.volunteers.each do |volunteer|
        if volunteer.to_receive_emails? && !volunteer.email_sent? && !volunteer.participant.nil?
          if volunteer.email_template_to_use == 'Sport Coordinator'
            VolunteerMailer.welcome(volunteer).deliver
            flash[:notice] = "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
            volunteer.email_sent!
            emails_sent += 1
          elsif volunteer.email_template_to_use == 'Default'
            VolunteerMailer.default_instructions(volunteer).deliver
            flash[:notice] = "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
            volunteer.email_sent!
            emails_sent += 1
          elsif volunteer.email_template_to_use == 'Override'
            VolunteerMailer.override(volunteer, test_run: true).deliver
            flash[:notice] = "Email sent to #{volunteer.email_recipients} for #{volunteer.description}"
            volunteer.email_sent!
            emails_sent += 1
          end
        end
      end

      respond_to do |format|
        if emails_sent > 0
          flash[:notice] = "#{emails_sent} emails sent successfully."
        else
          flash[:notice] = "No emails were sent."
        end
        format.html { render action: "edit" }
      end
    end

    # PATCH /admin/volunteer_types/1
    def update
        @volunteer_type.updated_by = current_user.id

        respond_to do |format|
          if @volunteer_type.update(volunteer_type_params)
            flash[:notice] = 'Volunteer type was successfully updated.'
            format.html { redirect_to admin_volunteer_types_url }
          else
            format.html { render action: "edit" }
          end
        end
    end
  
    # DELETE /volunteer_types/1
    def destroy
        @volunteer_type.updated_by = current_user.id

        @volunteer_type.destroy

        respond_to do |format|
            format.html { redirect_to admin_volunteer_types_url }
        end
    end

    # GET /admin/volunteer_types/new_import
    def new_import
      @volunteer_type = VolunteerType.new
    end
  
    # POST /admin/volunteer_types/import
    def import
      if params[:volunteer_type] && params[:volunteer_type][:file].path =~ %r{\.xlsx$}i
        result = VolunteerType.import_excel(params[:volunteer_type][:file], current_user)

        flash[:notice] = "Volunteer types upload complete: #{result[:creates]} volunteer types created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_volunteer_types_url }
        end
      else
        flash[:notice] = "Upload file must be in '.xlsx' format"
        @volunteer_type = VolunteerType.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end
  
  private
  
    def volunteer_type_params
      params.require(:volunteer_type).permit(:name, 
                                    :database_code, 
                                    :active,
                                    :sport_related,
                                    :t_shirt,
                                    :description,
                                    :age_category,
                                    :send_volunteer_email,
                                    :cc_email,
                                    :email_template,
                                    :instructions,
                                    :signature)
    end
end
