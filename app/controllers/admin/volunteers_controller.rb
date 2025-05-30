class Admin::VolunteersController < AdminController

    load_and_authorize_resource
    before_action :authenticate_user!
  
    # GET /admin/volunteers
    def index
      @volunteers = Volunteer.order(:description, :volunteer_type_id).all
  
      respond_to do |format|
        format.html {  }
        format.xlsx { render xlsx: "volunteers", template: "admin/volunteers/volunteers" }
      end
    end

    # GET /admin/volunteers/sat_coords
    def sat_coords
      @volunteers = Volunteer.sport_coords_saturday
  
      respond_to do |format|
        format.html { render 'sport_coords' }
      end
    end

    # GET /admin/volunteers/sun_coords
    def sun_coords
      @volunteers = Volunteer.sport_coords_sunday
  
      respond_to do |format|
        format.html { render 'sport_coords' }
      end
    end

    # GET /admin/volunteers/coords_notes
    def coord_notes
      @volunteers = Volunteer.sport_coords.order(:description).all
  
      respond_to do |format|
        format.xlsx { render xlsx: "sports_notes", template: "admin/volunteers/sports_notes" }
      end
    end

    # GET /admin/volunteers/sport_volunteers
    def sport_volunteers
      @volunteers = Volunteer.sport_volunteers
  
      respond_to do |format|
        format.html 
        format.xlsx { render xlsx: "sports_volunteers", template: "admin/volunteers/sports_volunteers" }
      end
    end

    # GET /admin/volunteers/search
    def search
      @volunteers = Volunteer.
        search(params[:search]).
        order(:description, :volunteer_type_id).load
  
      respond_to do |format|
        format.html { render action: 'index' }
      end
    end
  
    # GET /admin/volunteers/1
    def show
    end
  
    # GET /admin/volunteers/new
    def new
      @participants = Participant.volunteer_age.order("first_name, surname").load
      @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
      @volunteer_types = get_volunteer_types 
      @sessions = Session.order(:name).load
      @sections = Section.order(:name).load
    end
  
    # GET /admin/volunteers/1/edit
    def edit
      @participants = Participant.volunteer_age.order("first_name, surname").load
      @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
      @volunteer_types = get_volunteer_types 
      @sessions = Session.order(:name).load
      @sections = Section.order(:name).load
    end

    # GET /admin/volunteers/1/collect
    def collect
      prepare_for_sport_coords
    end
  
    # GET /admin/volunteers/1/return
    def return
      prepare_for_sport_coords
    end
  
    # POST /admin/volunteers
    def create
      @volunteer = Volunteer.new(volunteer_params)
      @volunteer.updated_by = current_user.id

      respond_to do |format|
        if @volunteer.save
          flash[:notice] = 'Volunteer was successfully created.'
          @participants = Participant.volunteer_age.order("first_name, surname").load
          @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
          @volunteer_types = get_volunteer_types 
          @sessions = Session.order(:name).load
          @sections = Section.order(:name).load

          format.html { render action: "edit" }
        else
          @participants = Participant.volunteer_age.order("first_name, surname").load
          @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
          @volunteer_types = get_volunteer_types 
          @sessions = Session.order(:name).load
          @sections = Section.order(:name).load

          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/volunteers/1
    def update
      @volunteer.updated_by = current_user.id

      respond_to do |format|
        if @volunteer.update(volunteer_params)
          flash[:notice] = 'Volunteer was successfully updated.'
          format.html { redirect_to admin_volunteers_url }
        else
          @participants = Participant.volunteer_age.order("first_name, surname").load
          @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
          @volunteer_types = get_volunteer_types 
          @sessions = Session.order(:name).load
          @sections = Section.order(:name).load

          format.html { render action: "edit" }
        end
      end
    end
  
    # PATCH /admin/volunteers/1/update_collect
    def update_collect
      @volunteer.updated_by = current_user.id

      respond_to do |format|
        if @volunteer.update(volunteer_params)
          flash[:notice] = 'Volunteer was successfully updated.'
          format.html { redirect_to sport_coord_return_path }
        else
          prepare_for_sport_coords
          format.html { render action: "collect" }
        end
      end
    end
  
    # PATCH /admin/volunteers/1/update_return
    def update_return
      @volunteer.updated_by = current_user.id

      respond_to do |format|
        if @volunteer.update(volunteer_params)
          flash[:notice] = 'Volunteer was successfully updated.'
          format.html { redirect_to sport_coord_return_path }
        else
          prepare_for_sport_coords
          format.html { render action: "return" }
        end
      end
    end

    # DELETE /volunteers/1
    def destroy
      @volunteer.updated_by = current_user.id

      @volunteer.destroy

      respond_to do |format|
        format.html { redirect_to admin_volunteers_url }
      end
    end

    # GET /admin/volunteers/new_import
    def new_import
      @volunteer = Volunteer.new
    end
  
    # POST /admin/volunteers/import
    def import
      if params[:volunteer] && params[:volunteer][:file].path =~ %r{\.xlsx$}i
        result = Volunteer.import_excel(params[:volunteer][:file], current_user)

        flash[:notice] = "Volunteers upload complete: #{result[:creates]} volunteers created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_volunteers_url }
        end
      else
        flash[:notice] = "Upload file must be in '.xlsx' format"
        @volunteer = Volunteer.new

        respond_to do |format|
          format.html { render action: "new_import" }
        end
      end
    end
  
  private
  
    def volunteer_params
      params.require(:volunteer).permit(:description, 
                                    :email, 
                                    :mobile_number,
                                    :t_shirt_size,
                                    :mobile_confirmed,
                                    :details_confirmed,
                                    :equipment_in,
                                    :equipment_out,
                                    :collected,
                                    :returned,
                                    :notes,
                                    :session_id,
                                    :participant_id,
                                    :volunteer_type_id,
                                    :email_strategy,
                                    :send_volunteer_email,
                                    :cc_email,
                                    :email_template,
                                    :instructions)
                                  
    end

    def get_volunteer_types
      VolunteerType.active.order('name').load 
    end

    def prepare_for_sport_coords
      group_id = @volunteer.participant.nil? ? nil : @volunteer.participant.group.id 
      if @volunteer.mobile_number.blank?
        @volunteer.mobile_number = @volunteer.participant.mobile_phone_number unless @volunteer.participant.nil?
      end
  
      if group_id.nil?
        @participants = Participant.volunteer_age.accepted.coming.order('first_name, surname').load
        @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
      else
        @participants = Participant.volunteer_age.coming.accepted.
          order("first_name, surname").
          where(['group_id = ?', group_id]).load
        @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
      end
    end

    def sport_coord_return_path
      if @volunteer.saturday?
        sat_coords_admin_volunteers_url
      else
        sun_coords_admin_volunteers_url
      end
    end
end
