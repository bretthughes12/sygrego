class Gc::VolunteersController < GcController
    load_and_authorize_resource
  
    # GET /gc/volunteers
    def index
      @volunteers = @group.volunteers
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end

    # GET /gc/volunteers/available
    def available
      @volunteers = Volunteer.unfilled.
        order(:description, :volunteer_type_id).load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
      end
    end

    # GET /gc/volunteers/search
    def search
      @volunteers = Volunteer.unfilled.
        search(params[:search]).
        order(:description, :volunteer_type_id).load
  
      respond_to do |format|
        format.html { render action: 'available', layout: @current_role.name }
      end
    end

    # GET /gc/volunteers/1
    def show
      render layout: @current_role.name
    end
  
    # GET /gc/volunteers/1/edit
    def edit
      if @volunteer.age_category == 'Over 18'
        @participants = @group.participants.open_age.coming.accepted.order("first_name, surname").load
      else
        @participants = @group.participants.volunteer_age.coming.accepted.order("first_name, surname").load
      end

      render layout: @current_role.name
    end
  
    # PATCH /gc/volunteers/1
    def update
      @volunteer.updated_by = current_user.id

      respond_to do |format|
        if @volunteer.update(volunteer_params)
          flash[:notice] = 'Details were successfully updated.'
          format.html { redirect_to gc_volunteers_url }
        else
          if @volunteer.age_category == 'Over 18'
            @participants = @group.participants.open_age.coming.accepted.order("first_name, surname").load
          else
            @participants = @group.participants.volunteer_age.coming.accepted.order("first_name, surname").load
          end
    
          format.html { render action: "edit", layout: @current_role.name }
        end
      end
    end
  
    # PATCH /gc/volunteers/1/release
    def release
      @volunteer.participant_id = nil
      @volunteer.mobile_number = nil
      @volunteer.email = nil
      @volunteer.t_shirt_size = nil

      @volunteer.updated_by = current_user.id

      respond_to do |format|
        if @volunteer.save
          flash[:notice] = 'Volunteer released.'
          format.html { redirect_to gc_volunteers_url }
        end
      end
    end

    private
  
    def volunteer_params
      params.require(:volunteer).permit( 
        :email, 
        :mobile_number,
        :t_shirt_size,
        :participant_id,
      )
    end
end
