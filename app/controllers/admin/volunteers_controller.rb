class Admin::VolunteersController < ApplicationController
    require 'csv'

    load_and_authorize_resource
    before_action :authenticate_user!
  
    layout "admin"
  
    # GET /admin/volunteers
    def index
      @volunteers = Volunteer.order(:description, :volunteer_type_id).all
  
      respond_to do |format|
        format.html {  }
        format.csv  { render_csv "volunteer" }
      end
    end

    # GET /admin/volunteers/sat_coords
    def sat_coords
      @volunteers = Volunteer.order(:description, :volunteer_type_id).all
  
      respond_to do |format|
        format.html {  }
        format.csv  { render_csv "volunteer" }
      end
    end

    # GET /admin/volunteers/sun_coords
    def sun_coords
      @volunteers = Volunteer.order(:description, :volunteer_type_id).all
  
      respond_to do |format|
        format.html {  }
        format.csv  { render_csv "volunteer" }
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
      @participants = Participant.open_age.order("first_name, surname").load
      @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
      @volunteer_types = get_volunteer_types 
      @sessions = Session.order(:name).load
      @sections = Section.order(:name).load
    end
  
    # GET /admin/volunteers/1/edit
    def edit
      @participants = Participant.open_age.order("first_name, surname").load
      @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
      @volunteer_types = get_volunteer_types 
      @sessions = Session.order(:name).load
      @sections = Section.order(:name).load
    end
  
    # POST /admin/volunteers
    def create
        @volunteer = Volunteer.new(volunteer_params)
        @volunteer.updated_by = current_user.id

        respond_to do |format|
            if @volunteer.save
              flash[:notice] = 'Volunteer was successfully created.'
              @participants = Participant.open_age.order("first_name, surname").load
              @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
              @volunteer_types = get_volunteer_types 
              @sessions = Session.order(:name).load
              @sections = Section.order(:name).load

              format.html { render action: "edit" }
            else
              @participants = Participant.open_age.order("first_name, surname").load
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
            @participants = Participant.open_age.order("first_name, surname").load
            @participants_with_group_name = @participants.map {|p| [p.name_with_group_name, p.id] }
            @volunteer_types = get_volunteer_types 
            @sessions = Session.order(:name).load
            @sections = Section.order(:name).load

            format.html { render action: "edit" }
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
      if params[:volunteer] && params[:volunteer][:file].path =~ %r{\.csv$}i
        result = Volunteer.import(params[:volunteer][:file], current_user)

        flash[:notice] = "Volunteers upload complete: #{result[:creates]} volunteers created; #{result[:updates]} updates; #{result[:errors]} errors"

        respond_to do |format|
          format.html { redirect_to admin_volunteers_url }
        end
      else
        flash[:notice] = "Upload file must be in '.csv' format"
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
                                    :section_id,
                                    :participant_id,
                                    :volunteer_type_id)
    end

    def get_volunteer_types
      VolunteerType.active.order('name').load 
    end
  end
