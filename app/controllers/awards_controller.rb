class AwardsController < ApplicationController

  load_and_authorize_resource
  layout 'users'
  
  # GET /awards/new_sport_nominations
  # GET /sport_nomination
  def new_good_sports
    @award = Award.new

    respond_to do |format|
      format.html # new_good_sports.html.erb
    end
  end
  
  # GET /awards/new_spirit
  # GET /spirit
  def new_spirit
    @award = Award.new

    respond_to do |format|
      format.html # new_spirit.html.erb
    end
  end
  
  # GET /awards/new_volunteer
  # GET /legend
  def new_volunteer
    @award = Award.new

    respond_to do |format|
      format.html # new_volunteer.html.erb
    end
  end

  # POST /awards/create_good_sports
  def create_good_sports
    @award = Award.new(award_params)
    @award.category = 'Good Sports'

    respond_to do |format|
      if @award.save
          flash[:notice] = 'Thanks for your nomination. Nominate another?'
          format.html do
            redirect_to sport_nomination_url
          end
      else
          format.html { render action: "new_good_sports" }
      end
    end
  end

  # POST /awards/create_spirit
  def create_spirit
    @award = Award.new(award_params)
    @award.category = 'Spirit'

    respond_to do |format|
      if @award.save
          flash[:notice] = 'Thanks for your nomination. Nominate another?'
          format.html do
            redirect_to spirit_url
          end
      else
          format.html { render action: "new_spirit" }
      end
    end
  end

  # POST /awards/create_volunteer
  def create_volunteer
    @award = Award.new(award_params)
    @award.category = 'Volunteer'

    respond_to do |format|
      if @award.save
          flash[:notice] = 'Thanks for your nomination. Nominate another?'
          format.html do
            redirect_to legend_url
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