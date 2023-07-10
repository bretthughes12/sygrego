class Sc::AwardsController < ScController

  load_and_authorize_resource
  
  # GET /sc/awards/new_sport_nominations
  def new_good_sports
    @award = Award.new

    respond_to do |format|
      format.html # new_good_sports.html.erb
    end
  end
  
  # GET /sc/awards/new_spirit
  def new_spirit
    @award = Award.new

    respond_to do |format|
      format.html # new_spirit.html.erb
    end
  end
  
  # GET /sc/awards/new_volunteer
  def new_volunteer
    @award = Award.new

    respond_to do |format|
      format.html # new_volunteer.html.erb
    end
  end

  # POST /sc/awards/create_good_sports
  def create_good_sports
    @award = Award.new(award_params)
    @award.category = 'Good Sports'

    respond_to do |format|
      if @award.save
          flash[:notice] = 'Thanks for your nomination. Nominate another?'
          format.html do
            redirect_to new_good_sports_sc_awards_url
          end
      else
          format.html { render action: "new_good_sports" }
      end
    end
  end

  # POST /sc/awards/create_spirit
  def create_spirit
    @award = Award.new(award_params)
    @award.category = 'Spirit'

    respond_to do |format|
      if @award.save
          flash[:notice] = 'Thanks for your nomination. Nominate another?'
          format.html do
            redirect_to new_spirit_sc_awards_url
          end
      else
          format.html { render action: "new_spirit" }
      end
    end
  end

  # POST /sc/awards/create_volunteer
  def create_volunteer
    @award = Award.new(award_params)
    @award.category = 'Volunteer'

    respond_to do |format|
      if @award.save
          flash[:notice] = 'Thanks for your nomination. Nominate another?'
          format.html do
            redirect_to new_volunteer_sc_awards_url
          end
      else
          format.html { render action: "new_volunteer" }
      end
    end
  end

  private

  def award_params
    params.require(:award).permit(
      :name, 
      :submitted_by, 
      :submitted_group,
      :description
    )
  end
end  